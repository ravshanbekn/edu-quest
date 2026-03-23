package kz.eduquest.gamification.repository;

import kz.eduquest.gamification.entity.UserLevel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserLevelRepository extends JpaRepository<UserLevel, UUID> {

    Optional<UserLevel> findByUserId(UUID userId);

    Page<UserLevel> findAllByOrderByTotalXpDesc(Pageable pageable);
}
