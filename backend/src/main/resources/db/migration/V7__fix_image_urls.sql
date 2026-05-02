UPDATE lesson_content
SET video_url = '/images/cartesian.svg'
WHERE content_type = 'IMAGE'
  AND video_url LIKE '%Cartesian-coordinate-system%';

UPDATE lesson_content
SET video_url = '/images/parabola.svg'
WHERE content_type = 'IMAGE'
  AND video_url LIKE '%Parabola_with_focus%';

UPDATE lesson_content
SET video_url = '/images/logarithm.svg'
WHERE content_type = 'IMAGE'
  AND video_url LIKE '%Log_different_bases%';

UPDATE lesson_content
SET video_url = '/images/unit-circle.svg'
WHERE content_type = 'IMAGE'
  AND video_url LIKE '%Unit_circle_angles%';

UPDATE lesson_content
SET video_url = '/images/tangent.svg'
WHERE content_type = 'IMAGE'
  AND video_url LIKE '%Tangent_to_a_curve%';

UPDATE lesson_content
SET video_url = '/images/integral.svg'
WHERE content_type = 'IMAGE'
  AND video_url LIKE '%Integral_as_region%';
