/**
 * =============================================================================
 * Users Service
 * =============================================================================
 * 
 * Business logic for user management.
 * =============================================================================
 */

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Create a new user.
   */
  async create(data: Partial<User>): Promise<User> {
    const user = this.userRepository.create(data);
    return this.userRepository.save(user);
  }

  /**
   * Find user by ID.
   */
  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  /**
   * Find user by email.
   */
  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  /**
   * Find user by Google ID.
   */
  async findByGoogleId(googleId: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { googleId } });
  }

  /**
   * Update user.
   */
  async update(id: string, data: Partial<User>): Promise<User> {
    await this.userRepository.update(id, data);
    const user = await this.findById(id);
    
    if (!user) {
      throw new NotFoundException('User not found');
    }
    
    return user;
  }

  /**
   * Delete user (soft delete by deactivating).
   */
  async delete(id: string): Promise<void> {
    await this.userRepository.update(id, { isActive: false });
  }

  /**
   * Update Google Calendar tokens.
   */
  async updateCalendarTokens(
    id: string,
    refreshToken: string,
  ): Promise<User> {
    return this.update(id, {
      googleRefreshToken: refreshToken,
      calendarConnected: true,
    });
  }

  /**
   * Disconnect Google Calendar.
   */
  async disconnectCalendar(id: string): Promise<User> {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    (user as any).googleRefreshToken = null;
    (user as any).googleAccessToken = null;
    user.calendarConnected = false;
    return this.userRepository.save(user);
  }
}
