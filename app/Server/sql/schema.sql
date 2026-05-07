DROP DATABASE IF EXISTS gamestack;
CREATE DATABASE gamestack;
USE gamestack;

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
-- Note: best_answer_id FK is added AFTER answer table exists.
--       This resolves the circular reference between the two tables.
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

-- -------------------------------------------------------------
-- Resolve circular reference: add best_answer_id FK now that
-- the answer table exists.
-- -------------------------------------------------------------
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
-- question_vote  (composite PK enforces one vote per user per question)
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
-- answer_vote  (composite PK enforces one vote per user per answer)
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