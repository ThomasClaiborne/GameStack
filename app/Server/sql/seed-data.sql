USE gamestack;

-- -------------------------------------------------------------
-- Clear existing data (order matters — child tables first)
-- -------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE answer_vote;
TRUNCATE TABLE question_vote;
TRUNCATE TABLE comment;
TRUNCATE TABLE answer;
TRUNCATE TABLE question;
TRUNCATE TABLE app_user;

SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------
-- Users
-- Passwords are all "Password1!" hashed with BCrypt.
-- Use these credentials to log in during development.
-- -------------------------------------------------------------
INSERT INTO app_user (id, username, email, password_hash) VALUES
(1, 'gamer_thomas',  'thomas@gamestack.com',  '$2a$10$NVM0n8ElaRgg7zWO1CxUdeiNbZroE2BQS9j.MR/LZhia1CXLQ4yR6'),
(2, 'xXProGamerXx',  'progamer@gamestack.com', '$2a$10$NVM0n8ElaRgg7zWO1CxUdeiNbZroE2BQS9j.MR/LZhia1CXLQ4yR6'),
(3, 'CryptoKnight99', 'crypto@gamestack.com',  '$2a$10$NVM0n8ElaRgg7zWO1CxUdeiNbZroE2BQS9j.MR/LZhia1CXLQ4yR6');

-- -------------------------------------------------------------
-- Questions
-- -------------------------------------------------------------
INSERT INTO question (id, user_id, title, body, best_answer_id) VALUES
(1, 1,
 'Best starting build for Elden Ring?',
 'I just started Elden Ring and I''m completely overwhelmed by the starting classes and stat system. What build would you recommend for a first-time player who wants a fair challenge without being punished too hard early on?',
 NULL),

(2, 2,
 'How do I beat Margit, the Fell Omen?',
 'I''ve attempted Margit about 20 times now and I keep dying during his second phase when he pulls out the hammer. I''m a level 18 Vagabond with a +2 longsword. Any tips on reading his attack patterns?',
 NULL),

(3, 1,
 'Is Red Dead Redemption 2 worth playing in 2025?',
 'I completely missed RDR2 when it launched. Is the story and open world still worth experiencing, or has it aged in ways that make it frustrating compared to modern games?',
 NULL),

(4, 3,
 'Most efficient rune farming spot pre-Altus Plateau?',
 'I need around 500k runes to level up enough to progress. I''m currently in Liurnia after beating Rennala. What''s the best farming location at this stage of the game?',
 NULL),

(5, 2,
 'Cyberpunk 2077 — is the ending worth doing all the side quests first?',
 'I''m near the point of no return in Cyberpunk and I''m wondering if it''s worth delaying the ending to complete all the side content first. Does it affect the ending outcome at all?',
 NULL);

-- -------------------------------------------------------------
-- Answers
-- -------------------------------------------------------------
INSERT INTO answer (id, user_id, question_id, body) VALUES
(1, 2, 1,
 'Vagabond is honestly the best starting class for beginners. High vigor and decent strength means you can tank hits while you learn the dodge timing. Prioritize leveling Vigor to 40 before anything else — most new players die because they have too few HP, not because their damage is too low.'),

(2, 3, 1,
 'I''d actually recommend the Astrologer if you want a more forgiving experience. Sorcery lets you deal damage from range which gives you more time to read enemy patterns. The downside is you''ll be squishy, so you still need to invest in Vigor.'),

(3, 1, 2,
 'The key to Margit phase 2 is not panicking when the golden hammer appears. He always does a 3-hit combo — dodge into the attacks, not away from them. Also make sure you have Margit''s Shackle from Patches in Murkwater Cave, it stuns him twice per fight and can be a lifesaver.'),

(4, 3, 3,
 'Absolutely worth it in 2025. The story is one of the best in gaming and the world detail is incredible. The gameplay is slower and more methodical than modern open world games, but once it clicks it''s deeply rewarding. Give it at least 5 hours before judging.'),

(5, 2, 4,
 'The best early spot is the Palace Approach Ledge-Road in Mohgwyn Palace, but you need to be further in the game. For pre-Altus, farm the knights near the Zamor Ruins in the Mountaintops — each gives about 3k runes and respawns quickly.');

-- -------------------------------------------------------------
-- Set best answers
-- -------------------------------------------------------------
UPDATE question SET best_answer_id = 3 WHERE id = 2;

-- -------------------------------------------------------------
-- Comments
-- -------------------------------------------------------------
INSERT INTO comment (id, user_id, answer_id, body) VALUES
(1, 3, 1, 'Completely agree on the Vigor tip. I had 20 Vigor at level 50 on my first playthrough and wondered why I was dying in two hits.'),
(2, 1, 3, 'The Margit Shackle tip is huge, I wish someone told me that earlier. I spent hours on that fight without it.'),
(3, 2, 4, 'The first chapter is slow but stick with it — the payoff is worth it.');

-- -------------------------------------------------------------
-- Votes
-- -------------------------------------------------------------
INSERT INTO question_vote (user_id, question_id, value) VALUES
(2, 1,  1),
(3, 1,  1),
(1, 2,  1),
(3, 2,  1),
(1, 3, -1),
(2, 4,  1);

INSERT INTO answer_vote (user_id, answer_id, value) VALUES
(1, 1,  1),
(3, 1,  1),
(2, 3,  1),
(1, 5,  1),
(3, 5, -1);