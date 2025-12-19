/**
 * =============================================================================
 * JWT Strategy
 * =============================================================================
 * 
 * Passport strategy for validating JWT access tokens.
 * =============================================================================
 */

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { AuthService, JwtPayload } from '../auth.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    private readonly authService: AuthService,
    configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  /**
   * Validate JWT payload and return user.
   * Called by Passport after token verification.
   */
  async validate(payload: JwtPayload) {
    const user = await this.authService.validateJwtPayload(payload);
    
    if (!user) {
      throw new UnauthorizedException();
    }
    
    return user;
  }
}
