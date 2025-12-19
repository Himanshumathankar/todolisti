/**
 * =============================================================================
 * Auth Controller
 * =============================================================================
 * 
 * Handles authentication endpoints for Google OAuth and token refresh.
 * =============================================================================
 */

import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Req,
  Res,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { Request, Response } from 'express';

import { AuthService, TokenResponse } from './auth.service';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Initiate Google OAuth flow.
   * Redirects to Google login page.
   */
  @Get('google')
  @UseGuards(AuthGuard('google'))
  @ApiOperation({ summary: 'Initiate Google OAuth login' })
  @ApiResponse({ status: 302, description: 'Redirects to Google login' })
  googleAuth() {
    // Guard handles redirect
  }

  /**
   * Google OAuth callback.
   * Called by Google after user authorization.
   */
  @Get('google/callback')
  @UseGuards(AuthGuard('google'))
  @ApiOperation({ summary: 'Google OAuth callback' })
  @ApiResponse({ status: 200, description: 'Returns access tokens' })
  async googleAuthCallback(
    @Req() req: Request & { user: any },
    @Res() res: Response,
  ) {
    const tokens = await this.authService.googleLogin(req.user);
    
    // For mobile apps, redirect with tokens in query params
    // For web apps, you might set cookies instead
    const redirectUrl = new URL(process.env.FRONTEND_URL || 'http://localhost:8080');
    redirectUrl.pathname = '/auth/callback';
    redirectUrl.searchParams.set('accessToken', tokens.accessToken);
    redirectUrl.searchParams.set('refreshToken', tokens.refreshToken);
    
    res.redirect(redirectUrl.toString());
  }

  /**
   * Mobile/Flutter Google sign-in.
   * Accepts Google ID token from client-side authentication.
   */
  @Post('google/mobile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Google sign-in for mobile apps' })
  @ApiResponse({ status: 200, description: 'Returns access tokens' })
  @ApiResponse({ status: 401, description: 'Invalid Google ID token' })
  async googleMobileAuth(
    @Body() body: { idToken: string },
  ): Promise<TokenResponse> {
    return this.authService.verifyGoogleIdToken(body.idToken);
  }

  /**
   * Refresh access token.
   */
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token' })
  @ApiResponse({ status: 200, description: 'Returns new access tokens' })
  @ApiResponse({ status: 401, description: 'Invalid refresh token' })
  async refreshToken(@Body() dto: RefreshTokenDto): Promise<TokenResponse> {
    return this.authService.refreshTokens(dto.refreshToken);
  }

  /**
   * Get current user profile.
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'Returns user profile' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProfile(@CurrentUser() user: User) {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      timezone: user.timezone,
      calendarConnected: user.calendarConnected,
      createdAt: user.createdAt,
    };
  }

  /**
   * Logout (optional - mainly for token blacklisting).
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Logout user' })
  @ApiResponse({ status: 204, description: 'Successfully logged out' })
  async logout(@CurrentUser() user: User) {
    // Optionally blacklist the token in Redis
    // For now, client just discards the token
    return;
  }
}
