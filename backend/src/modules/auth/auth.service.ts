/**
 * =============================================================================
 * Auth Service
 * =============================================================================
 * 
 * Handles authentication logic including Google OAuth, JWT generation,
 * and token refresh.
 * =============================================================================
 */

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';

import { UsersService } from '../users/users.service';
import { User } from '../users/entities/user.entity';

/**
 * JWT payload structure.
 */
export interface JwtPayload {
  sub: string;      // User ID
  email: string;
  iat?: number;     // Issued at
  exp?: number;     // Expiration
}

/**
 * Token response structure.
 */
export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: Partial<User>;
}

/**
 * Google profile from OAuth callback.
 */
export interface GoogleProfile {
  id: string;
  email: string;
  name: string;
  picture?: string;
  accessToken: string;
  refreshToken?: string;
}

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {
    this.googleClient = new OAuth2Client(
      this.configService.get<string>('GOOGLE_CLIENT_ID'),
    );
  }

  /**
   * Verify Google ID token from mobile/client-side auth.
   * 
   * @param idToken - Google ID token from client
   * @returns Token response with user info
   */
  async verifyGoogleIdToken(idToken: string): Promise<TokenResponse> {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
      });

      const payload = ticket.getPayload();
      if (!payload) {
        throw new UnauthorizedException('Invalid Google ID token');
      }

      const { sub: googleId, email, name, picture } = payload;

      if (!email) {
        throw new UnauthorizedException('Email not provided by Google');
      }

      // Find or create user
      let user = await this.usersService.findByGoogleId(googleId);

      if (!user) {
        // Check if user exists by email
        user = await this.usersService.findByEmail(email);

        if (user) {
          // Link Google account to existing user
          user = await this.usersService.update(user.id, {
            googleId,
          });
        } else {
          // Create new user
          user = await this.usersService.create({
            email,
            name: name || email.split('@')[0],
            avatarUrl: picture,
            googleId,
          });
        }
      }

      // Update last login
      await this.usersService.update(user.id, { lastLoginAt: new Date() });

      // Generate tokens
      return this.generateTokens(user);
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      console.error('Google ID token verification failed:', error);
      throw new UnauthorizedException('Invalid Google ID token');
    }
  }

  /**
   * Authenticate user with Google OAuth profile.
   * Creates a new user if one doesn't exist.
   * 
   * @param profile - Google OAuth profile
   * @returns Token response with user info
   */
  async googleLogin(profile: GoogleProfile): Promise<TokenResponse> {
    // Find or create user
    let user = await this.usersService.findByGoogleId(profile.id);
    
    if (!user) {
      // Check if user exists by email
      user = await this.usersService.findByEmail(profile.email);
      
      if (user) {
        // Link Google account to existing user
        user = await this.usersService.update(user.id, {
          googleId: profile.id,
          googleRefreshToken: profile.refreshToken,
        });
      } else {
        // Create new user
        user = await this.usersService.create({
          email: profile.email,
          name: profile.name,
          avatarUrl: profile.picture,
          googleId: profile.id,
          googleRefreshToken: profile.refreshToken,
        });
      }
    } else {
      // Update refresh token if provided
      if (profile.refreshToken) {
        user = await this.usersService.update(user.id, {
          googleRefreshToken: profile.refreshToken,
          lastLoginAt: new Date(),
        });
      }
    }
    
    // Update last login
    await this.usersService.update(user.id, { lastLoginAt: new Date() });
    
    // Generate tokens
    return this.generateTokens(user);
  }

  /**
   * Refresh access token using refresh token.
   * 
   * @param refreshToken - JWT refresh token
   * @returns New token response
   */
  async refreshTokens(refreshToken: string): Promise<TokenResponse> {
    try {
      const payload = this.jwtService.verify<JwtPayload>(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });
      
      const user = await this.usersService.findById(payload.sub);
      
      if (!user || !user.isActive) {
        throw new UnauthorizedException('Invalid refresh token');
      }
      
      return this.generateTokens(user);
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  /**
   * Validate JWT payload and return user.
   * 
   * @param payload - JWT payload
   * @returns User entity
   */
  async validateJwtPayload(payload: JwtPayload): Promise<User> {
    const user = await this.usersService.findById(payload.sub);
    
    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }
    
    return user;
  }

  /**
   * Generate access and refresh tokens.
   * 
   * @param user - User entity
   * @returns Token response
   */
  private generateTokens(user: User): TokenResponse {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
    };
    
    const accessToken = this.jwtService.sign(payload);
    
    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRES_IN', '7d'),
    });
    
    // Calculate expiration in seconds
    const expiresIn = this.parseExpiresIn(
      this.configService.get<string>('JWT_EXPIRES_IN', '15m'),
    );
    
    return {
      accessToken,
      refreshToken,
      expiresIn,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        avatarUrl: user.avatarUrl,
      },
    };
  }

  /**
   * Parse expiration string to seconds.
   * Supports formats like: 15m, 1h, 7d
   */
  private parseExpiresIn(expiresIn: string): number {
    const match = expiresIn.match(/^(\d+)([smhd])$/);
    if (!match) return 900; // Default 15 minutes
    
    const value = parseInt(match[1], 10);
    const unit = match[2];
    
    switch (unit) {
      case 's': return value;
      case 'm': return value * 60;
      case 'h': return value * 3600;
      case 'd': return value * 86400;
      default: return 900;
    }
  }
}
