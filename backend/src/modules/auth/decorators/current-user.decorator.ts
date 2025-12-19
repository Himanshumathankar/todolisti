/**
 * =============================================================================
 * Current User Decorator
 * =============================================================================
 * 
 * Extracts the current authenticated user from the request.
 * =============================================================================
 */

import { createParamDecorator, ExecutionContext } from '@nestjs/common';

import { User } from '../../users/entities/user.entity';

/**
 * Decorator to get the current authenticated user.
 * 
 * @example
 * ```typescript
 * @Get('profile')
 * getProfile(@CurrentUser() user: User) {
 *   return user;
 * }
 * ```
 */
export const CurrentUser = createParamDecorator(
  (data: keyof User | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as User;
    
    return data ? user?.[data] : user;
  },
);
