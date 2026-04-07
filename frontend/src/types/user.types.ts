export interface UserResponse {
  id: string;
  email: string;
  active: boolean;
  roles: string[];
  createdAt: string;
}

export interface ProfileResponse {
  userId: string;
  displayName: string | null;
  avatarUrl: string | null;
  bio: string | null;
  isPublic: boolean;
}

export interface UpdateProfileRequest {
  displayName?: string;
  bio?: string;
  isPublic?: boolean;
}

export interface UpdateRolesRequest {
  roles: string[];
}
