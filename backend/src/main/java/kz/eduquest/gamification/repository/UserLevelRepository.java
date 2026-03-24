package kz.eduquest.gamification.repository;

import kz.eduquest.gamification.entity.UserLevel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserLevelRepository extends JpaRepository<UserLevel, Long> {

    Optional<UserLevel> findByUserId(Long userId);

    Page<UserLevel> findAllByOrderByTotalXpDesc(Pageable pageable);
}
