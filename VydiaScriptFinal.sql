-- Limpeza
DROP TABLE IF EXISTS receive            CASCADE;
DROP TABLE IF EXISTS Guardian           CASCADE;
DROP TABLE IF EXISTS Grades             CASCADE;
DROP TABLE IF EXISTS Reports            CASCADE;
DROP TABLE IF EXISTS Students           CASCADE;
DROP TABLE IF EXISTS Class              CASCADE;
DROP TABLE IF EXISTS Subjects           CASCADE;
DROP TABLE IF EXISTS Teachers           CASCADE;
DROP TABLE IF EXISTS Administrators     CASCADE;
DROP TABLE IF EXISTS PreRegistration    CASCADE;
DROP TABLE IF EXISTS TeachingAssignment CASCADE;

-- =========================================================
-- Tabelas principais
-- =========================================================

CREATE TABLE Teachers (
    id_employee SERIAL PRIMARY KEY,
    full_name   VARCHAR(200) NOT NULL,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    birth_date  DATE,
    phone       VARCHAR(16),
    login       VARCHAR(120) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE Subjects (
    id_subject  SERIAL PRIMARY KEY,
    description TEXT,
    name        VARCHAR(120) UNIQUE NOT NULL
);

CREATE TABLE Class (
    id_class      SERIAL PRIMARY KEY,
    series        CHAR(1) NOT NULL,
    classroom     CHAR(1) NOT NULL,
    academic_year SMALLINT NOT NULL
);

CREATE TABLE Guardian (
    id_guardian SERIAL PRIMARY KEY,
    full_name   VARCHAR(200),
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    birth_date  DATE
);

-- IMPORTANTE:
-- Usamos sentinelas (id=0) para fk_class e fk_guardian. Portanto:
-- - DEFAULT 0
-- - NOT NULL
-- - ON DELETE SET DEFAULT  (assim, se o pai for apagado, volta para 0)
CREATE TABLE Students (
    id_student   BIGINT PRIMARY KEY,
    fk_class     INTEGER NOT NULL
                          DEFAULT 0
                          REFERENCES Class(id_class)
                          ON DELETE SET DEFAULT
                          ON UPDATE CASCADE,
    fk_guardian  INTEGER NOT NULL
                          DEFAULT 0
                          REFERENCES Guardian(id_guardian)
                          ON DELETE SET DEFAULT
                          ON UPDATE CASCADE,
    full_name    VARCHAR(200) NOT NULL,
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    birth_date   DATE,
    login        VARCHAR(120) UNIQUE NOT NULL,
    password     VARCHAR(255) NOT NULL,
    phone        VARCHAR(16),
    created_at   TIMESTAMP DEFAULT NOW()
);

CREATE TABLE TeachingAssignment (
    id          SERIAL PRIMARY KEY,
    fk_class    INTEGER NOT NULL REFERENCES Class(id_class) ON DELETE CASCADE,
    fk_subject  INTEGER NOT NULL REFERENCES Subjects(id_subject) ON DELETE CASCADE,
    fk_teacher  INTEGER NOT NULL REFERENCES Teachers(id_employee) ON DELETE CASCADE,
    class_num   INTEGER NOT NULL,
    CONSTRAINT ck_teaching_assignment_class_num CHECK (class_num BETWEEN 1 AND 6),
    CONSTRAINT uq_teaching_assignment UNIQUE (fk_class, fk_subject, fk_teacher, class_num)
);

CREATE TABLE PreRegistration (
    id         SERIAL PRIMARY KEY,
    fk_student BIGINT UNIQUE REFERENCES Students(id_student)
                      ON UPDATE CASCADE,
    cpf        CHAR(11) UNIQUE NOT NULL
);

CREATE TABLE Grades (
    id_grade   SERIAL PRIMARY KEY,
    fk_student BIGINT  NOT NULL REFERENCES Students(id_student) ON DELETE CASCADE,
    fk_subject INTEGER NOT NULL REFERENCES Subjects(id_subject) ON DELETE CASCADE,
    grade_type CHAR(1),
    value      NUMERIC(4,2),
    send_at    TIMESTAMP DEFAULT NOW(),
    CONSTRAINT uq_grades_context UNIQUE (fk_student, fk_subject, grade_type)
);

CREATE TABLE Reports (
    id          SERIAL PRIMARY KEY,
    fk_teacher  INTEGER NOT NULL
                       DEFAULT 0
                       REFERENCES Teachers(id_employee)
                       ON DELETE SET DEFAULT
                       ON UPDATE CASCADE,
    description TEXT,
    send_at     TIMESTAMP DEFAULT NOW(),
    type        TEXT,
    CONSTRAINT reports_type_list
        CHECK (type IN ('Elogio','Aviso','Informativo') OR type IS NULL)
);

CREATE TABLE Administrators (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(200),
    birth_date DATE,
    type       TEXT,
    login      VARCHAR(120) UNIQUE NOT NULL,
    password   VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================================================
-- Tabelas auxiliares
-- =========================================================

CREATE TABLE receive (
    id         SERIAL PRIMARY KEY,
    fk_student BIGINT  NOT NULL REFERENCES Students(id_student) ON DELETE CASCADE,
    fk_report  INTEGER     REFERENCES Reports(id)              ON DELETE CASCADE,
    CONSTRAINT uq_receive UNIQUE (fk_student, fk_report)
);

-- =========================================================
-- Proteção das linhas sentinelas (id=0) | Procedures
-- =========================================================

-- Teachers: impede excluir a linha sentinela
CREATE OR REPLACE FUNCTION protect_teacher_sentinel()
RETURNS trigger AS $$
BEGIN
  IF OLD.id_employee = 0 THEN
    RAISE EXCEPTION 'Linha sentinela de Teachers (id=0) não pode ser excluída.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_teacher_sentinel
BEFORE DELETE ON Teachers
FOR EACH ROW
WHEN (OLD.id_employee = 0)
EXECUTE FUNCTION protect_teacher_sentinel();

-- Class: impede excluir a linha sentinela
CREATE OR REPLACE FUNCTION protect_class_sentinel()
RETURNS trigger AS $$
BEGIN
  IF OLD.id_class = 0 THEN
    RAISE EXCEPTION 'Linha sentinela de Class (id=0) não pode ser excluída.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_class_sentinel
BEFORE DELETE ON Class
FOR EACH ROW
WHEN (OLD.id_class = 0)
EXECUTE FUNCTION protect_class_sentinel();

-- Guardian: impede excluir a linha sentinela
CREATE OR REPLACE FUNCTION protect_guardian_sentinel()
RETURNS trigger AS $$
BEGIN
  IF OLD.id_guardian = 0 THEN
    RAISE EXCEPTION 'Linha sentinela de Guardian (id=0) não pode ser excluída.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_guardian_sentinel
BEFORE DELETE ON Guardian
FOR EACH ROW
WHEN (OLD.id_guardian = 0)
EXECUTE FUNCTION protect_guardian_sentinel();

-- =========================================================
-- População
-- =========================================================

-- 1) Professores (Teachers) - inclui sentinela id=0
WITH t AS (
    INSERT INTO Teachers (id_employee, full_name, first_name, last_name, birth_date, phone, login, password)
    VALUES
    (0, 'Professor desligado',     '',        '',          '1900-01-01', '',            'xxx.xxx',           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92'),
    (1, 'Ana Paula Souza',         'Ana',     'Souza',     '1985-03-12', '11981234567', 'ana.souza',         '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92'),
    (2, 'Bruno Henrique Lima',     'Bruno',   'Lima',      '1979-11-25', '11982345678', 'bruno.lima',        '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92'),
    (3, 'Carla Menezes',           'Carla',   'Menezes',   '1990-07-03', '11983456789', 'carla.menezes',     '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92'),
    (4, 'Diego Albuquerque',       'Diego',   'Albuquerque','1983-09-14','11984567890', 'diego.albuquerque', '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92'),
    (5, 'Eduarda Ribeiro',         'Eduarda', 'Ribeiro',   '1988-02-27', '11985678901', 'eduarda.ribeiro',   '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92')
    RETURNING id_employee, login
)
SELECT 1;

-- 2) Disciplinas (Subjects)
WITH s AS (
    INSERT INTO Subjects (description, name) VALUES
    ('Língua Portuguesa do ensino fundamental', 'Português'),
    ('Matemática do ensino fundamental',        'Matemática'),
    ('Ciências Naturais',                       'Ciências'),
    ('História do Brasil e Geral',              'História'),
    ('Geografia do Brasil e do Mundo',          'Geografia'),
    ('Educação Física e Saúde',                 'Educação Física')
    RETURNING id_subject, name
)
SELECT 1;

-- 3) Turmas (Class) — inclui sentinela id=0
WITH c AS (
    INSERT INTO Class (id_class, series, classroom, academic_year) VALUES
    (0, '0', 'Z', 1990),
    (1, '5', 'A', 2024),
    (2, '6', 'B', 2025),
    (3, '7', 'C', 2026)
    RETURNING id_class, series, classroom, academic_year
)
SELECT 1;

-- 4) Responsáveis (Guardian) — inclui sentinela id=0
WITH g AS (
    INSERT INTO Guardian (id_guardian, full_name, first_name, last_name, birth_date) VALUES
    (0, 'Guardião apagado',   '',         '',          '1900-01-01'),
    (1, 'Mariana Alves',      'Mariana',  'Alves',     '1982-02-10'),
    (2, 'José Roberto Silva', 'José',     'Silva',     '1978-09-08'),
    (3, 'Patrícia Gomes',     'Patrícia', 'Gomes',     '1986-12-22'),
    (4, 'Rogério Pereira',    'Rogério',  'Pereira',   '1975-05-03'),
    (5, 'Luciana Andrade',    'Luciana',  'Andrade',   '1984-10-19')
    RETURNING id_guardian, full_name
)
SELECT 1;

-- 5) Alunos (Students)
WITH alunos AS (
    SELECT
        floor(random() * (999999 - 100000 + 1) + 100000)::bigint AS id_student,
        1 AS id_class, 1 AS id_guardian,
        'Lucas Alves' AS full_name, 'Lucas' AS first_name, 'Alves' AS last_name,
        '2013-05-14'::date AS birth_date, 'lucas.alves' AS login,
        '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92' AS password,
        '11991110001' AS phone
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 1, 2,
           'Beatriz Silva','Beatriz','Silva','2013-08-20','beatriz.silva',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11991110002'
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 1, 3,
           'Caio Gomes','Caio','Gomes','2013-02-11','caio.gomes',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11991110003'
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 2, 2,
           'Rafael Silva','Rafael','Silva','2012-03-02','rafael.silva',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11992220001'
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 2, 4,
           'Isabela Pereira','Isabela','Pereira','2012-11-11','isabela.pereira',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11992220002'
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 3, 1,
           'Pedro Alves','Pedro','Alves','2011-01-29','pedro.alves',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11993330001'
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 3, 5,
           'Ana Andrade','Ana','Andrade','2011-06-07','ana.andrade',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11993330002'
    UNION ALL
    SELECT floor(random() * (999999 - 100000 + 1) + 100000)::bigint, 3, 3,
           'Bruna Gomes','Bruna','Gomes','2011-09-18','bruna.gomes',
           '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92','11993330003'
)
INSERT INTO Students (id_student, fk_class, fk_guardian, full_name, first_name, last_name, birth_date, login, password, phone)
SELECT id_student, id_class, id_guardian, full_name, first_name, last_name, birth_date, login, password, phone
FROM alunos
RETURNING id_student, login;

-- 6) Pré-matrícula (PreRegistration)
INSERT INTO PreRegistration (fk_student, cpf)
SELECT s.id_student, v.cpf
FROM Students s
JOIN (VALUES
  ('lucas.alves',     '12345678901'),
  ('beatriz.silva',   '23456789012'),
  ('caio.gomes',      '34567890123'),
  ('rafael.silva',    '45678901234'),
  ('isabela.pereira', '56789012345'),
  ('pedro.alves',     '67890123456'),
  ('ana.andrade',     '78901234567'),
  ('bruna.gomes',     '89012345678')
) AS v(login, cpf)
  ON s.login = v.login;

-- 7) Atribuições de ensino (TeachingAssignment)

-- Turma 2024 (series '5', classroom 'A')
INSERT INTO TeachingAssignment (fk_class, fk_subject, fk_teacher, class_num)
SELECT c.id_class, subj.id_subject, t.id_employee, x.class_num
FROM (VALUES
  ('Português',       'ana.souza',          1),
  ('Matemática',      'bruno.lima',         2),
  ('Ciências',        'carla.menezes',      3),
  ('História',        'bruno.lima',         4),
  ('Educação Física', 'eduarda.ribeiro',    5)
) AS x(subj_name, login, class_num)
JOIN Subjects subj ON subj.name = x.subj_name
JOIN Teachers t    ON t.login = x.login
JOIN Class c       ON c.series = '5' AND c.classroom = 'A';

-- Turma 2025 (series '6', classroom 'B')
INSERT INTO TeachingAssignment (fk_class, fk_subject, fk_teacher, class_num)
SELECT c.id_class, subj.id_subject, t.id_employee, x.class_num
FROM (VALUES
  ('Português',       'ana.souza',          1),
  ('Matemática',      'bruno.lima',         2),
  ('Geografia',       'diego.albuquerque',  3),
  ('Educação Física', 'eduarda.ribeiro',    4)
) AS x(subj_name, login, class_num)
JOIN Subjects subj ON subj.name = x.subj_name
JOIN Teachers t    ON t.login = x.login
JOIN Class c       ON c.series = '6' AND c.classroom = 'B';

-- Turma 2026 (series '7', classroom 'C')
INSERT INTO TeachingAssignment (fk_class, fk_subject, fk_teacher, class_num)
SELECT c.id_class, subj.id_subject, t.id_employee, x.class_num
FROM (VALUES
  ('Português',       'carla.menezes',      1),
  ('Matemática',      'bruno.lima',         2),
  ('Ciências',        'ana.souza',          3),
  ('História',        'bruno.lima',         4),
  ('Geografia',       'diego.albuquerque',  5),
  ('Educação Física', 'eduarda.ribeiro',    6)
) AS x(subj_name, login, class_num)
JOIN Subjects subj ON subj.name = x.subj_name
JOIN Teachers t    ON t.login = x.login
JOIN Class c       ON c.series = '7' AND c.classroom = 'C';

-- 8) Reports (Relatórios)
WITH r AS (
  INSERT INTO Reports (fk_teacher, description, type)
  SELECT t.id_employee, v.description, v.type
  FROM (VALUES
    ('ana.souza',          'Turma demonstrou excelente desempenho em leitura.',   'Elogio'),
    ('bruno.lima',         'Aviso sobre conversas paralelas que prejudicam aula.','Aviso'),
    ('carla.menezes',      'Informativo: calendário de avaliações do bimestre.',  'Informativo'),
    ('eduarda.ribeiro',    'Elogio ao engajamento nas aulas de Ed. Física.',     'Elogio')
  ) AS v(login, description, type)
  JOIN Teachers t ON t.login = v.login
  RETURNING id
)
SELECT 1;

-- 9) Administrators
WITH admins AS (
    INSERT INTO Administrators (name, birth_date, type, login, password)
    VALUES
    ('Lorenzo Lima',     '2000-01-01', 'admin', 'lorenzo.lima',
     '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92'),
    ('Vini Vilas Boas',  '2000-01-01', 'admin', 'vini.vilasboas',
     '8D969EEF6ECAD3C29A3A629280E686CF0C3F5D5A86AFF3CA12020C923ADC6C92')
    RETURNING id, login
)
SELECT 1;

-- 10) receive (quem recebeu qual relatório)
INSERT INTO receive (fk_student, fk_report)
SELECT s.id_student, 1
FROM Students s
WHERE s.login IN ('lucas.alves','beatriz.silva','rafael.silva');

INSERT INTO receive (fk_student, fk_report)
SELECT s.id_student, 2
FROM Students s
WHERE s.login IN ('isabela.pereira');

INSERT INTO receive (fk_student, fk_report)
SELECT s.id_student, 3
FROM Students s;

INSERT INTO receive (fk_student, fk_report)
SELECT s.id_student, 4
FROM Students s
WHERE s.login IN ('ana.andrade','bruna.gomes');