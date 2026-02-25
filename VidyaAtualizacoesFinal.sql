--=============================================================================
-- Criando a tabela Address
--=============================================================================
CREATE TABLE IF NOT EXISTS Address (
    id_address       SERIAL PRIMARY KEY,
    postal_code      CHAR(8)
        CONSTRAINT address_cep
        CHECK (postal_code ~ '^[0-9]{8}$'),
    formated_address TEXT,
    street           VARCHAR(150),
    number           VARCHAR(10),
    neighborhood     VARCHAR(80),
    city             VARCHAR(80),
    state            CHAR(2)
);

--=============================================================================
-- Adicionando as colunas id_address em Students e Teachers
--=============================================================================
ALTER TABLE Students
ADD COLUMN IF NOT EXISTS id_address_student INTEGER;

ALTER TABLE Teachers
ADD COLUMN IF NOT EXISTS id_address_teacher INTEGER;

--=============================================================================
-- Criar as FKs (agora que as colunas existem)
--=============================================================================
ALTER TABLE Students
ADD CONSTRAINT fk_address_student
FOREIGN KEY (id_address_student)
REFERENCES Address (id_address);

ALTER TABLE Teachers
ADD CONSTRAINT fk_address_teacher
FOREIGN KEY (id_address_teacher)
REFERENCES Address (id_address);
--=============================================================================
--Adicionando o campo img que vai guardar as url da imagem de perfil do usuário
--=============================================================================
ALTER TABLE Students 
ADD COLUMN profile_image_url VARCHAR(255);

ALTER TABLE Teachers
ADD COLUMN profile_image_url VARCHAR(255);

-- ============================================================================
-- Removendo constraint not null da table Students
--=============================================================================
ALTER TABLE Students
ALTER COLUMN fk_class DROP NOT NULL;

-- ============================================================================
-- População após as mudanças
-- ============================================================================
-- ============================
-- Address para TEACHERS
-- ============================
INSERT INTO Address (id_address, postal_code, formated_address, street, number, neighborhood, city, state)
VALUES
  (101, '01310000',
   'Av. Paulista, 1000 - Bela Vista, São Paulo/SP - CEP 01310000',
   'Av. Paulista', '1000', 'Bela Vista', 'São Paulo', 'SP'),
   
  (102, '20040002',
   'Rua da Assembléia, 200 - Centro, Rio de Janeiro/RJ - CEP 20040002',
   'Rua da Assembléia', '200', 'Centro', 'Rio de Janeiro', 'RJ'),

  (103, '30140071',
   'Av. Afonso Pena, 1200 - Centro, Belo Horizonte/MG - CEP 30140071',
   'Av. Afonso Pena', '1200', 'Centro', 'Belo Horizonte', 'MG');

-- Vinculando os endereços aos professores
UPDATE Teachers SET id_address_teacher = 101 WHERE id_employee = 1; 
UPDATE Teachers SET id_address_teacher = 102 WHERE id_employee = 2; 
UPDATE Teachers SET id_address_teacher = 103 WHERE id_employee = 3; 

-- ============================
-- Address para STUDENTS
-- ============================
INSERT INTO Address (id_address, postal_code, formated_address, street, number, neighborhood, city, state)
VALUES
  (201, '04094000',
   'Rua Domingos de Morais, 500 - Vila Mariana, São Paulo/SP - CEP 04094000',
   'Rua Domingos de Morais', '500', 'Vila Mariana', 'São Paulo', 'SP'),

  (202, '22290040',
   'Praia de Botafogo, 400 - Botafogo, Rio de Janeiro/RJ - CEP 22290040',
   'Praia de Botafogo', '400', 'Botafogo', 'Rio de Janeiro', 'RJ'),

  (203, '30130010',
   'Av. Amazonas, 800 - Centro, Belo Horizonte/MG - CEP 30130010',
   'Av. Amazonas', '800', 'Centro', 'Belo Horizonte', 'MG');

-- Vinculando os endereços aos alunos
UPDATE Students SET id_address_student = 201 WHERE id_student = 749023; 
UPDATE Students SET id_address_student = 202 WHERE id_student = 742870; 
UPDATE Students SET id_address_student = 203 WHERE id_student = 697517; 