package kz.eduquest.course.service;

import kz.eduquest.course.dto.*;
import kz.eduquest.course.entity.Block;
import kz.eduquest.course.entity.Course;
import kz.eduquest.course.repository.BlockRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BlockService {

    private final BlockRepository blockRepository;
    private final CourseService courseService;

    @Transactional
    public BlockResponse create(UUID userId, boolean isAdmin, UUID courseId, CreateBlockRequest request) {
        Course course = courseService.findCourseOrThrow(courseId);
        courseService.checkOwnerOrAdmin(course, userId, isAdmin);

        int nextOrder = blockRepository.findByCourseIdOrderBySortOrder(courseId).size();

        Block block = Block.builder()
                .course(course)
                .title(request.title())
                .sortOrder(nextOrder)
                .build();
        return BlockResponse.from(blockRepository.save(block));
    }

    @Transactional
    public BlockResponse update(UUID userId, boolean isAdmin, UUID blockId, UpdateBlockRequest request) {
        Block block = findBlockOrThrow(blockId);
        courseService.checkOwnerOrAdmin(block.getCourse(), userId, isAdmin);

        if (request.title() != null) block.setTitle(request.title());

        return BlockResponse.from(blockRepository.save(block));
    }

    @Transactional
    public void delete(UUID userId, boolean isAdmin, UUID blockId) {
        Block block = findBlockOrThrow(blockId);
        courseService.checkOwnerOrAdmin(block.getCourse(), userId, isAdmin);
        blockRepository.delete(block);
    }

    @Transactional
    public List<BlockResponse> reorder(UUID userId, boolean isAdmin, UUID courseId, ReorderRequest request) {
        Course course = courseService.findCourseOrThrow(courseId);
        courseService.checkOwnerOrAdmin(course, userId, isAdmin);

        List<UUID> orderedIds = request.orderedIds();
        for (int i = 0; i < orderedIds.size(); i++) {
            Block block = findBlockOrThrow(orderedIds.get(i));
            block.setSortOrder(i);
            blockRepository.save(block);
        }

        return blockRepository.findByCourseIdOrderBySortOrder(courseId)
                .stream().map(BlockResponse::from).toList();
    }

    Block findBlockOrThrow(UUID blockId) {
        return blockRepository.findById(blockId)
                .orElseThrow(() -> new IllegalArgumentException("Block not found: " + blockId));
    }
}
