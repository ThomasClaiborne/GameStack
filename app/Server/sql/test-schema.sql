DROP DATABASE IF EXISTS gamestack_test;
CREATE DATABASE gamestack_test;
USE gamestack_test;

-- -------------------------------------------------------------
-- app_user
-- -------------------------------------------------------------
CREATE TABLE app_user (
    id            INT             PRIMARY KEY AUTO_INCREMENT,
    created_at    TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP       NOT NULL DEFAULT NOW(),
    username      VARCHAR(50)     NOT NULL UNIQUE,
    email         VARCHAR(255)    NOT NULL UNIQUE,
    password_hash VARCHAR(255)    NOT NULL
);

-- -------------------------------------------------------------
-- question
-- -------------------------------------------------------------
CREATE TABLE question (
    id             INT          PRIMARY KEY AUTO_INCREMENT,
    created_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
    user_id        INT          NOT NULL,
    title          VARCHAR(255) NOT NULL,
    body           TEXT         NOT NULL,
    best_answer_id INT          NULL,
    CONSTRAINT fk_question_user
        FOREIGN KEY (user_id) REFERENCES app_user(id)
);

-- -------------------------------------------------------------
-- answer
-- -------------------------------------------------------------
CREATE TABLE answer (
    id          INT       PRIMARY KEY AUTO_INCREMENT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    user_id     INT       NOT NULL,
    question_id INT       NOT NULL,
    body        TEXT      NOT NULL,
    CONSTRAINT fk_answer_user
        FOREIGN KEY (user_id)     REFERENCES app_user(id),
    CONSTRAINT fk_answer_question
        FOREIGN KEY (question_id) REFERENCES question(id)
);

ALTER TABLE question
    ADD CONSTRAINT fk_question_best_answer
        FOREIGN KEY (best_answer_id) REFERENCES answer(id);

-- -------------------------------------------------------------
-- comment
-- -------------------------------------------------------------
CREATE TABLE comment (
    id          INT       PRIMARY KEY AUTO_INCREMENT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    user_id     INT       NOT NULL,
    answer_id   INT       NOT NULL,
    body        TEXT      NOT NULL,
    CONSTRAINT fk_comment_user
        FOREIGN KEY (user_id)   REFERENCES app_user(id),
    CONSTRAINT fk_comment_answer
        FOREIGN KEY (answer_id) REFERENCES answer(id)
);

-- -------------------------------------------------------------
-- question_vote
-- -------------------------------------------------------------
CREATE TABLE question_vote (
    user_id     INT NOT NULL,
    question_id INT NOT NULL,
    value       INT NOT NULL,
    CONSTRAINT pk_question_vote
        PRIMARY KEY (user_id, question_id),
    CONSTRAINT fk_qvote_user
        FOREIGN KEY (user_id)     REFERENCES app_user(id),
    CONSTRAINT fk_qvote_question
        FOREIGN KEY (question_id) REFERENCES question(id)
);

-- -------------------------------------------------------------
-- answer_vote
-- -------------------------------------------------------------
CREATE TABLE answer_vote (
    user_id   INT NOT NULL,
    answer_id INT NOT NULL,
    value     INT NOT NULL,
    CONSTRAINT pk_answer_vote
        PRIMARY KEY (user_id, answer_id),
    CONSTRAINT fk_avote_user
        FOREIGN KEY (user_id)   REFERENCES app_user(id),
    CONSTRAINT fk_avote_answer
        FOREIGN KEY (answer_id) REFERENCES answer(id)
);

-- =============================================================
-- set_known_good_state
-- Called before each repository integration test to reset the
-- database to a predictable state.
-- Java equivalent: your set_known_good_state stored procedure.
-- =============================================================
DELIMITER //
CREATE PROCEDURE set_known_good_state()
BEGIN
    -- Disable FK checks so we can truncate in any order
    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE answer_vote;
    TRUNCATE TABLE question_vote;
    TRUNCATE TABLE comment;
    TRUNCATE TABLE answer;
    TRUNCATE TABLE question;
    TRUNCATE TABLE app_user;

    SET FOREIGN_KEY_CHECKS = 1;

    -- ── Users ──────────────────────────────────────────────
    INSERT INTO app_user (id, username, email, password_hash) VALUES
    (1, 'test_user1', 'user1@test.com', '$2a$10$hashhashhashhashhashhashhashhashhashhashhashhash1'),
    (2, 'test_user2', 'user2@test.com', '$2a$10$hashhashhashhashhashhashhashhashhashhashhashhash2'),
    (3, 'test_user3', 'user3@test.com', '$2a$10$hashhashhashhashhashhashhashhashhashhashhashhash3');

    -- ── Questions ──────────────────────────────────────────
    INSERT INTO question (id, user_id, title, body, best_answer_id) VALUES
    (1, 1, 'Test Question One',   'Body of test question one.',   NULL),
    (2, 1, 'Test Question Two',   'Body of test question two.',   NULL),
    (3, 2, 'Test Question Three', 'Body of test question three.', NULL);

    -- ── Answers ────────────────────────────────────────────
    INSERT INTO answer (id, user_id, question_id, body) VALUES
    (1, 2, 1, 'Answer one for question one.'),
    (2, 3, 1, 'Answer two for question one.'),
    (3, 1, 2, 'Answer one for question two.');

    -- ── Set a best answer on question 1 ────────────────────
    UPDATE question SET best_answer_id = 1 WHERE id = 1;

    -- ── Comments ───────────────────────────────────────────
    INSERT INTO comment (id, user_id, answer_id, body) VALUES
    (1, 3, 1, 'Comment on answer one.'),
    (2, 1, 1, 'Another comment on answer one.');

    -- ── Votes ──────────────────────────────────────────────
    INSERT INTO question_vote (user_id, question_id, value) VALUES
    (2, 1,  1),
    (3, 1,  1),
    (1, 2, -1);

    INSERT INTO answer_vote (user_id, answer_id, value) VALUES
    (1, 1,  1),
    (3, 2, -1);

END //
DELIMITER ;