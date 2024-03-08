SELECT name,
    to_char(pr_per_week, '99.9') AS pr_per_week,
    to_char(lowest_pr_per_week, '99.9') || ' - ' || to_char(highest_pr_per_week, '99.9') AS pr_range,
    WIDTH_BUCKET(pr_per_week, 0, 5, 5) AS pr_per_week_bucket,
    to_char(avg_change_size, '999999') AS avg_change_size,
    to_char(lowest_avg_change_size, '999999') || ' - ' || to_char(highest_avg_change_size, '999999') AS size_range,
    WIDTH_BUCKET(avg_change_size, 1, 250, 5) AS avg_change_size_bucket
FROM (
        SELECT name,
            pr_per_week,
            avg_change_size,
            FIRST_VALUE (pr_per_week) OVER (
                ORDER BY pr_per_week
            ) AS lowest_pr_per_week,
            FIRST_VALUE (pr_per_week) OVER (
                ORDER BY pr_per_week DESC
            ) as highest_pr_per_week,
            FIRST_VALUE (avg_change_size) OVER (
                ORDER BY avg_change_size
            ) AS lowest_avg_change_size,
            FIRST_VALUE (avg_change_size) OVER (
                ORDER BY avg_change_size DESC
            ) as highest_avg_change_size
        FROM (
                SELECT COALESCE(author_name, author_login) AS name,
                    count(*) AS count,
                    count(*) / 22.0 AS pr_per_week,
                    SUM(additions) AS additions_count,
                    SUM(deletions) AS deletions_count,
                    (
                        SUM(
                            CASE
                                WHEN additions > 250 THEN 250
                                ELSE additions
                            END
                        ) + SUM(
                            CASE
                                WHEN deletions > 250 THEN 250
                                ELSE deletions
                            END
                        )
                    ) / count(*) AS avg_change_size
                FROM github_pull_requests
                WHERE created_at >= '2023-07-01'
                    AND created_at < '2024-01-01'
                    AND state = 'MERGED'
                    AND author_login != 'dependabot'
                    AND author_login != 'github-actions'
                    AND COALESCE(author_name, author_login) IN (
                        SELECT COALESCE(author_name, author_login)
                        FROM github_pull_requests
                        WHERE created_at >= '2023-07-01'
                            AND created_at < '2024-01-01'
                    )
                    AND COALESCE(author_name, author_login) IN (
                        SELECT COALESCE(author_name, author_login)
                        FROM github_pull_requests
                        WHERE created_at >= '2023-07-01'
                    )
                GROUP BY 1
            ) AS foo
        WHERE count > 10
    ) as foo2;
