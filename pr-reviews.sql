SELECT reviewer,
    count(creator) AS count_reviews_for,
    SUM(count) AS total_reviews,
    SUM(count)::DOUBLE PRECISION / 22::DOUBLE PRECISION AS reviews_per_week,
    WIDTH_BUCKET(
        SUM(count)::DOUBLE PRECISION / 22::DOUBLE PRECISION,
        0,
        5,
        5
    ) AS pr_per_week_bucket
FROM (
        SELECT prr.author_login AS reviewer,
            pr.author_login AS creator,
            count(*) AS count
        FROM github_pull_request_reviews prr,
            github_pull_requests pr
        WHERE prr.repo_id = pr.repo_id
            AND prr.pr_number = pr.number
            AND prr.created_at >= '2022-07-01'
            AND prr.created_at < '2023-01-01'
            AND pr.author_login != 'dependabot'
            AND prr.state = 'APPROVED'
        GROUP BY 1,
            2
    ) AS foo
GROUP BY 1
ORDER BY 5 DESC;