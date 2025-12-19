/**
 * =============================================================================
 * Google OAuth Strategy
 * =============================================================================
 * 
 * Passport strategy for Google OAuth 2.0 authentication.
 * =============================================================================
 */

import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { Strategy, VerifyCallback, Profile } from 'passport-google-oauth20';

import { GoogleProfile } from '../auth.service';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(configService: ConfigService) {
    super({
      clientID: configService.get<string>('GOOGLE_CLIENT_ID'),
      clientSecret: configService.get<string>('GOOGLE_CLIENT_SECRET'),
      callbackURL: configService.get<string>('GOOGLE_CALLBACK_URL'),
      scope: ['email', 'profile', 'openid'],
      accessType: 'offline',  // Required for refresh token
      prompt: 'consent',      // Force consent screen to get refresh token
    });
  }

  /**
   * Validate Google OAuth callback and extract profile.
   */
  async validate(
    accessToken: string,
    refreshToken: string,
    profile: Profile,
    done: VerifyCallback,
  ): Promise<void> {
    const { id, emails, displayName, photos } = profile;
    
    const googleProfile: GoogleProfile = {
      id,
      email: emails?.[0]?.value || '',
      name: displayName,
      picture: photos?.[0]?.value,
      accessToken,
      refreshToken,
    };
    
    done(null, googleProfile);
  }
}
