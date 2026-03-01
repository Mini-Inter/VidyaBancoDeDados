-- ============================
-- Address para TEACHERS
-- ============================
INSERT INTO Address (id_address, postal_code, formated_address, street, number, neighborhood, city, state)
VALUES
  (104, '01319999',
   'Av. Jardins, 999 - Jabuticacira, São Paulo/SP - CEP 01319999',
   'Av. Jardins', '999', 'Jabuticacira', 'São Paulo', 'SP'),
   
  (105, '20048882',
   'Rua da fé, 300 - Morro, São Paulo/SP - CEP 20048882',
   'Rua da fé', '300', 'Morro', 'São Paulo', 'SP');

-- Vinculando os endereços aos professores
UPDATE Teachers SET id_address_teacher = 104 WHERE id_employee = 4; 
UPDATE Teachers SET id_address_teacher = 105 WHERE id_employee = 5; 

-- ============================
-- Address para Students
-- ============================
INSERT INTO Address (id_address, postal_code, formated_address, street, number, neighborhood, city, state)
VALUES
  (204, '76543289',
   'Rua Emeniano, 600 - Vila Caparaó, São Paulo/SP - CEP 76543289',
   'Rua Emeniano', '600', 'Vila Caparaó', 'São Paulo', 'SP'),

  (205, '93425678',
   'Praia de Tuquinique, 800 - Juíz de Fora, Rio de Janeiro/RJ - CEP 93425678',
   'Praia de Tuquinique', '800', 'Juíz de Fora', 'Rio de Janeiro', 'RJ'),

  (206, '09871435',
   'Av. Loucola, 200 - Centro, Belo Horizonte/MG - CEP 09871435',
   'Av. Loucola', '200', 'Centro', 'Belo Horizonte', 'MG'),

  (207, '76253418',
   'Rua Bonita, 100 - Vila Mariana, São Paulo/SP - CEP 76253418',
   'Rua Bonita', '100', 'Vila Mariana', 'São Paulo', 'SP'),

  (208, '93846357',
   'Beira do mar, 980 - Orla, Rio de Janeiro/RJ - CEP 93846357',
   'Beira do mar', '980', 'Orla', 'Rio de Janeiro', 'RJ'),

  (209, '23456719',
   'Av. Sudique, 300 - Centro, Belo Horizonte/MG - CEP 23456719',
   'Av. Sudique', '300', 'Centro', 'Belo Horizonte', 'MG');
   
-- Vinculando os endereços aos alunos
UPDATE Students SET id_address_student = 201 WHERE id_student = 308115; 
UPDATE Students SET id_address_student = 202 WHERE id_student = 253998; 
UPDATE Students SET id_address_student = 203 WHERE id_student = 299469; 
UPDATE Students SET id_address_student = 204 WHERE id_student = 422805; 
UPDATE Students SET id_address_student = 205 WHERE id_student = 160229; 
UPDATE Students SET id_address_student = 206 WHERE id_student = 957048; 
UPDATE Students SET id_address_student = 207 WHERE id_student = 661561; 
UPDATE Students SET id_address_student = 208 WHERE id_student = 498671; 
UPDATE Students SET id_address_student = 209 WHERE id_student = 908730; 

