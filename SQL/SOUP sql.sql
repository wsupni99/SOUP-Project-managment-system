-- ====== СОЗДАНИЕ СХЕМ ======
-- СХЕМА: project
CREATE TABLE project.projects (
    project_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status TEXT,
    manager_id INT REFERENCES core.users(user_id)
);

CREATE TABLE project.sprints (
    sprint_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES project.projects(project_id),
    name TEXT NOT NULL,
    start_date DATE,
    end_date DATE
);

CREATE TABLE project.tasks (
    task_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    priority TEXT,
    status TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deadline DATE,
    parent_task_id INT REFERENCES project.tasks(task_id),
    project_id INT REFERENCES project.projects(project_id),
    sprint_id INT REFERENCES project.sprints(sprint_id)
);

CREATE TABLE project.task_assignments (
    task_id INT REFERENCES project.tasks(task_id),
    user_id INT REFERENCES core.users(user_id),
    PRIMARY KEY (task_id, user_id)
);

CREATE TABLE project.comments (
    comment_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES project.tasks(task_id),
    user_id INT REFERENCES core.users(user_id),
    text TEXT,
    created_at TIMESTAMP
);

CREATE TABLE project.attachments (
    attachment_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES project.tasks(task_id),
    filename TEXT,
    file_url TEXT,
    filetype TEXT
);

CREATE TABLE project.task_log (
    log_id SERIAL PRIMARY KEY,
    task_id INT REFERENCES project.tasks(task_id),
    user_id INT REFERENCES core.users(user_id),
    action TEXT,
    changed_at TIMESTAMP
);

-- СХЕМА: core
CREATE TABLE core.roles (
    role_id SERIAL PRIMARY KEY,
    role_name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE core.permissions (
    permission_id SERIAL PRIMARY KEY,
    permission_name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE core.users (
    user_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    contact_info TEXT
);

CREATE TABLE core.user_roles (
    user_id INT REFERENCES core.users(user_id),
    role_id INT REFERENCES core.roles(role_id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE core.role_permissions (
    role_id INT REFERENCES core.roles(role_id),
    permission_id INT REFERENCES core.permissions(permission_id),
    PRIMARY KEY (role_id, permission_id)
);

INSERT INTO project.sprints 

-- СХЕМА: analytics
CREATE TABLE analytics.workload_summary (
    summary_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES core.users(user_id),
    project_id INT REFERENCES project.projects(project_id),
    open_tasks_count INT,
    closed_tasks_count INT,
    sprint_id INT REFERENCES project.sprints(sprint_id)
);
-- НАПОЛНЕНИЕ ДАННЫМИ (тестовые)

-- Роли
INSERT INTO core.roles (role_name, description) VALUES
('Администратор', 'Полные права'),
('Менеджер', 'Управление проектами и задачами'),
('Разработчик', 'Исполнитель задач'),
('Тестировщик', 'Тестирование и комментарии');

-- Права
INSERT INTO core.permissions (permission_name, description) VALUES
('CREATE_PROJECT', 'Создание проектов'),
('EDIT_TASK', 'Редактирование задач'),
('VIEW_ALL', 'Просмотр всех данных');

-- Пользователи
INSERT INTO core.users (name, email, password_hash, contact_info) VALUES
('Иван Иванов', 'ivan@example.com', 'hash1', 'Москва'),
('Мария Смирнова', 'maria@example.com', 'hash2', 'Санкт-Петербург'),
('Петр Кузнецов', 'peter@example.com', 'hash3', 'Казань'),
('Ольга Тестова', 'olga@example.com', 'hash4', 'Новосибирск');

-- user_roles
INSERT INTO core.user_roles (user_id, role_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4);

-- role_permissions
INSERT INTO core.role_permissions (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), (3, 2), (4, 3);

-- Проекты
INSERT INTO project.projects (name, description, start_date, end_date, status, manager_id) VALUES
('CRM Внедрение', 'Внедрение CRM-системы', '2025-01-01', '2025-05-01', 'активен', 2),
('Миграция сервера', 'Перенос серверов в облако', '2025-02-01', '2025-04-15', 'на паузе', 1);

-- Спринты
INSERT INTO project.sprints (project_id, name, start_date, end_date) VALUES
(1, 'Sprint 001', '2025-01-01', '2025-01-14'),
(1, 'Sprint 002', '2025-01-15', '2025-01-28'),
(2, 'Sprint Alpha', '2025-02-01', '2025-02-14');

-- Задачи
INSERT INTO project.tasks
    (name, description, priority, status, created_at, updated_at, deadline, project_id, sprint_id)
VALUES
('Создать прототип', 'Разработать макет для CRM', 'высокий', 'новая', '2025-01-01', '2025-01-01', '2025-01-10', 1, 1),
('Собрать требования', 'Интервью с клиентами', 'средний', 'новая', '2025-01-02', '2025-01-02', '2025-01-12', 1, 1),
('Настроить сервер', 'Переустановка ПО', 'высокий', 'новая', '2025-02-02', '2025-02-02', '2025-02-10', 2, 3);

-- Назначения задач
INSERT INTO project.task_assignments (task_id, user_id) VALUES
(1, 3), (1, 2), (2, 2), (3, 1);

-- Комментарии
INSERT INTO project.comments (task_id, user_id, text, created_at) VALUES
(1, 3, 'Прототип будет готов завтра', '2025-01-05'),
(2, 2, 'Получены первые требования от клиента', '2025-01-03'),
(3, 1, 'Начал настройку сервера', '2025-02-04');

-- Вложения
INSERT INTO project.attachments (task_id, filename, file_url, filetype) VALUES
(1, 'crm_mockup_v1.png', 'https://fileserver/crm1.png', 'png'),
(2, 'requirements.docx', 'https://fileserver/req.docx', 'docx'),
(3, 'server_setup.txt', 'https://fileserver/setup.txt', 'txt');

-- Журнал изменений задач
INSERT INTO project.task_log (task_id, user_id, action, changed_at) VALUES
(1, 3, 'created', '2025-01-01'),
(2, 2, 'created', '2025-01-02'),
(1, 3, 'commented', '2025-01-05'),
(3, 1, 'assigned', '2025-02-02');

-- Аналитика
INSERT INTO analytics.workload_summary (user_id, project_id, open_tasks_count, closed_tasks_count, sprint_id) VALUES
(2, 1, 4, 2, 1),
(3, 1, 2, 1, 1),
(1, 2, 5, 0, 3);

-- ====== КОММЕНТЕРИИ К ТАБЛИЦАМ ======
COMMENT ON TABLE core.users IS 'Пользователи системы управления проектами';
COMMENT ON COLUMN core.users.user_id IS 'Идентификатор пользователя (PK)';
COMMENT ON COLUMN core.users.name IS 'ФИО или никнейм пользователя';
COMMENT ON COLUMN core.users.email IS 'Электронная почта, уникальна для каждого пользователя';
COMMENT ON COLUMN core.users.password_hash IS 'Хэш пароля пользователя';
COMMENT ON COLUMN core.users.contact_info IS 'Контактная информация (например, номер телефона)';

COMMENT ON TABLE core.roles IS 'Роли пользователя (админ, менеджер, разработчик, тестировщик)';
COMMENT ON COLUMN core.roles.role_id IS 'Идентификатор роли (PK)';
COMMENT ON COLUMN core.roles.role_name IS 'Название роли';
COMMENT ON COLUMN core.roles.description IS 'Описание роли';

COMMENT ON TABLE core.permissions IS 'Права доступа для разграничения возможностей пользователя';
COMMENT ON COLUMN core.permissions.permission_id IS 'Идентификатор права (PK)';
COMMENT ON COLUMN core.permissions.permission_name IS 'Название права (например, CREATE_PROJECT)';
COMMENT ON COLUMN core.permissions.description IS 'Описание права доступа';

COMMENT ON TABLE core.user_roles IS 'Связь многие ко многим между пользователями и ролями';
COMMENT ON COLUMN core.user_roles.user_id IS 'Ссылка на пользователя (FK)';
COMMENT ON COLUMN core.user_roles.role_id IS 'Ссылка на роль (FK)';

COMMENT ON TABLE core.role_permissions IS 'Связь многие ко многим между ролями и правами';
COMMENT ON COLUMN core.role_permissions.role_id IS 'Ссылка на роль (FK)';
COMMENT ON COLUMN core.role_permissions.permission_id IS 'Ссылка на право доступа (FK)';

COMMENT ON TABLE project.projects IS 'Проекты, реализуемые в системе';
COMMENT ON COLUMN project.projects.project_id IS 'Идентификатор проекта (PK)';
COMMENT ON COLUMN project.projects.name IS 'Название проекта';
COMMENT ON COLUMN project.projects.description IS 'Описание проекта';
COMMENT ON COLUMN project.projects.start_date IS 'Дата начала работы над проектом';
COMMENT ON COLUMN project.projects.end_date IS 'Дата окончания проекта';
COMMENT ON COLUMN project.projects.status IS 'Статус проекта (активен, завершен, на паузе)';
COMMENT ON COLUMN project.projects.manager_id IS 'Руководитель проекта (FK на пользователя)';

COMMENT ON TABLE project.sprints IS 'Спринты (итерации) в проекте';
COMMENT ON COLUMN project.sprints.sprint_id IS 'Идентификатор спринта (PK)';
COMMENT ON COLUMN project.sprints.project_id IS 'Ссылка на проект (FK)';
COMMENT ON COLUMN project.sprints.name IS 'Название спринта';
COMMENT ON COLUMN project.sprints.start_date IS 'Дата начала спринта';
COMMENT ON COLUMN project.sprints.end_date IS 'Дата окончания спринта';

COMMENT ON TABLE project.tasks IS 'Задачи в проекте';
COMMENT ON COLUMN project.tasks.task_id IS 'Идентификатор задачи (PK)';
COMMENT ON COLUMN project.tasks.name IS 'Название задачи (кратко)';
COMMENT ON COLUMN project.tasks.description IS 'Описание задачи (подробно)';
COMMENT ON COLUMN project.tasks.priority IS 'Приоритет задачи (высокий, средний, низкий)';
COMMENT ON COLUMN project.tasks.status IS 'Текущий статус задачи';
COMMENT ON COLUMN project.tasks.created_at IS 'Дата и время создания';
COMMENT ON COLUMN project.tasks.updated_at IS 'Дата и время последнего изменения';
COMMENT ON COLUMN project.tasks.deadline IS 'Дедлайн по задаче';
COMMENT ON COLUMN project.tasks.parent_task_id IS 'Родительская задача (для иерархии подзадач)';
COMMENT ON COLUMN project.tasks.project_id IS 'Проект, к которому относится задача (FK)';
COMMENT ON COLUMN project.tasks.sprint_id IS 'Спринт, в который входит задача (FK)';

COMMENT ON TABLE project.task_assignments IS 'Назначения задач пользователям (многие ко многим)';
COMMENT ON COLUMN project.task_assignments.task_id IS 'Ссылка на задачу (FK)';
COMMENT ON COLUMN project.task_assignments.user_id IS 'Ссылка на пользователя (FK)';

COMMENT ON TABLE project.comments IS 'Комментарии к задачам';
COMMENT ON COLUMN project.comments.comment_id IS 'Идентификатор комментария (PK)';
COMMENT ON COLUMN project.comments.task_id IS 'Задача, к которой относится комментарий (FK)';
COMMENT ON COLUMN project.comments.user_id IS 'Пользователь — автор комментария (FK)';
COMMENT ON COLUMN project.comments.text IS 'Текст комментария';
COMMENT ON COLUMN project.comments.created_at IS 'Дата и время создания комментария';

COMMENT ON TABLE project.attachments IS 'Вложения (файлы, скриншоты) к задачам';
COMMENT ON COLUMN project.attachments.attachment_id IS 'Идентификатор вложения (PK)';
COMMENT ON COLUMN project.attachments.task_id IS 'Ссылка на задачу (FK)';
COMMENT ON COLUMN project.attachments.filename IS 'Имя файла вложения';
COMMENT ON COLUMN project.attachments.file_url IS 'Ссылка на файл/вложение (URL)';
COMMENT ON COLUMN project.attachments.filetype IS 'Тип файла (расширение)';

COMMENT ON TABLE project.task_log IS 'Журнал изменений задач (лог)';
COMMENT ON COLUMN project.task_log.log_id IS 'Идентификатор события (PK)';
COMMENT ON COLUMN project.task_log.task_id IS 'Задача, с которой связано событие (FK)';
COMMENT ON COLUMN project.task_log.user_id IS 'Пользователь, выполнивший действие (FK)';
COMMENT ON COLUMN project.task_log.action IS 'Тип совершённого действия (created, updated, etc)';
COMMENT ON COLUMN project.task_log.changed_at IS 'Дата и время совершения действия';

COMMENT ON TABLE analytics.workload_summary IS 'Агрегированные аналитические данные по пользователям/проектам/спринтам';
COMMENT ON COLUMN analytics.workload_summary.summary_id IS 'Идентификатор записи (PK)';
COMMENT ON COLUMN analytics.workload_summary.user_id IS 'Пользователь (FK)';
COMMENT ON COLUMN analytics.workload_summary.project_id IS 'Проект (FK)';
COMMENT ON COLUMN analytics.workload_summary.open_tasks_count IS 'Количество открытых задач у пользователя по проекту/спринту';
COMMENT ON COLUMN analytics.workload_summary.closed_tasks_count IS 'Количество закрытых задач у пользователя по проекту/спринту';
COMMENT ON COLUMN analytics.workload_summary.sprint_id IS 'Спринт (FK)';

-- ====== НАПОЛНЕНИЕ ДАННЫМИ ======
ALTER TABLE tasks
ADD COLUMN user_id INTEGER;

ALTER TABLE tasks
ADD CONSTRAINT fk_tasks_user
FOREIGN KEY (user_id) REFERENCES core.users(user_id);

SELECT * FROM tasks;

DROP TABLE IF EXISTS task_assignments;

SELECT obj_description('core.users'::regclass), col_description('core.users'::regclass, ordinal_position)
FROM information_schema.columns WHERE table_name = 'users';

INSERT INTO project.projects (name, description, start_date, end_date, status, manager_id) VALUES
('CRM Внедрение', 'Внедрение CRM-системы', '2025-01-01', '2025-06-01', 'активен', 2),
('Миграция сервера', 'Перенос серверов в облако', '2025-02-01', '2025-05-15', 'на паузе', 1),
('Мобильный портал', 'Разработка мобильного приложения', '2025-03-01', '2025-10-01', 'активен', 3);

INSERT INTO project.sprints (project_id, name, start_date, end_date) VALUES
(1, 'Sprint 1', '2025-01-03', '2025-01-17'), (1, 'Sprint 2', '2025-01-18', '2025-02-01'), (1, 'Sprint 3', '2025-02-02', '2025-02-15'),
(2, 'Alpha',    '2025-02-02', '2025-02-28'), (2, 'Beta',    '2025-03-01', '2025-03-25'),
(3, 'Design',   '2025-03-05', '2025-04-05'), (3, 'Dev',     '2025-04-06', '2025-05-10'), (3, 'Test', '2025-05-11', '2025-05-31'), (3, 'Release', '2025-06-01', '2025-09-01');

INSERT INTO project.tasks (name, description, priority, status, created_at, updated_at, deadline, project_id, sprint_id)
SELECT
  'Задача №' || gs,
  'Описание задачи ' || gs,
  CASE WHEN gs % 4 = 0 THEN 'высокий' WHEN gs % 4 = 1 THEN 'средний' WHEN gs % 4 = 2 THEN 'низкий' ELSE 'критичный' END,
  CASE WHEN gs % 5 = 0 THEN 'новая' WHEN gs % 5 = 1 THEN 'в работе' WHEN gs % 5 = 2 THEN 'тест' WHEN gs % 5 = 3 THEN 'готова' ELSE 'отложена' END,
  '2025-01-01'::timestamp + (gs * interval '12 hour'),
  '2025-01-01'::timestamp + (gs * interval '18 hour'),
  '2025-06-01'::date - (gs % 83),
  1 + (gs % 3),           -- проекты 1-3
  1 + (gs % 9)            -- спринты 1-9
FROM generate_series(1, 1200) AS gs;


INSERT INTO project.tasks (name, ..., user_id)
SELECT 'Task' || gs, ..., (1 + (gs % 4))
FROM generate_series(1, 1200) AS gs;


INSERT INTO project.tasks
    (name, description, priority, status, created_at, updated_at, deadline, parent_task_id, project_id, sprint_id, user_id)
SELECT
    'Task_' || gs,                              
    'Описание задачи ' || gs,                   
    CASE WHEN gs % 4 = 0 THEN 'высокий'
         WHEN gs % 4 = 1 THEN 'средний'
         WHEN gs % 4 = 2 THEN 'низкий'
         ELSE 'критичный' END,                  
    CASE WHEN gs % 5 = 0 THEN 'новая'
         WHEN gs % 5 = 1 THEN 'в работе'
         WHEN gs % 5 = 2 THEN 'тест'
         WHEN gs % 5 = 3 THEN 'готова'
         ELSE 'отложена' END,
    '2025-01-01'::timestamp + (gs * interval '12 hour'),
    '2025-01-01'::timestamp + (gs * interval '18 hour'),
    '2025-06-01'::date - (gs % 83),            
    NULL,                                      
    1 + (gs % 3),
    1 + (gs % 9),
    1 + (gs % 4)
FROM generate_series(1, 1200) AS gs;

INSERT INTO project.attachments (task_id, filename, file_url, filetype)
SELECT
  t.task_id,
  'taskfile_' || t.task_id || '.png',
  'https://fileserver/taskfile_' || t.task_id || '.png',
  'png'
FROM project.tasks t
WHERE t.task_id % 3 = 0 AND t.task_id <= 1200;

INSERT INTO analytics.workload_summary (user_id, project_id, open_tasks_count, closed_tasks_count, sprint_id)
SELECT 
    1 + (gs % 4),
    1 + (gs % 3),
    gs % 23,
    gs % 18,
    1 + (gs % 9)
FROM generate_series(1, 300) AS gs;

INSERT INTO core.users (name, email, password_hash, contact_info)
SELECT
    'User_' || gs,
    'user' || gs || '@example.com',
    'hash' || gs,
    'город ' || (1 + (gs % 10))
FROM generate_series(5, 50) AS gs;

UPDATE project.tasks
SET user_id = CASE
    WHEN task_id % 5 = 0 THEN NULL
    ELSE 1 + ((task_id - 1) % 50)
END;
WITH texts AS (
  SELECT unnest(ARRAY[
    'Выполнил часть задачи, осталось согласовать с командой.',
    'Нужно уточнить требования у заказчика.',
    'В этой задаче нужна помощь тестировщика.',
    'Все готово, можно переходить к следующему этапу.',
    'Нашёл баг в функционале, описал выше.',
    'Документ отправил, проверьте, пожалуйста.',
    'Сделал рефакторинг кода, стало быстрее.',
    'Продвигаюсь медленно, есть сложности.',
    'Давайте обсудим на утренней встрече.',
    'Извините за задержку, завтра пришлю результат.',
    'Данные обновлены, проверьте и согласуйте.',
    'Добавил вложение, посмотрите изменения.',
    'Уточните кто будет ответственным за этот модуль.',
    'Завтра проведу финальное тестирование.',
    'Прошу всех посмотреть новые правки!',
    'Прикрепил прототип интерфейса.',
    'Задача выполнена, закрываю.',
    'Запланировал задачу на следующий спринт.',
    'Проблемы с подключением к серверу, ищу решение.',
    'Сделал быстрый hotfix перед релизом.'
  ]) AS ready_text
)
INSERT INTO project.comments (task_id, user_id, text, created_at)
SELECT
  t.task_id,
  1 + ((cs + t.task_id) % 50),
  txt.ready_text,
  now() - (cs * interval '2 hour')
FROM project.tasks t,
LATERAL generate_series(1, (2 + t.task_id%4)) cs,
texts txt
WHERE txt.ready_text IS NOT NULL AND cs <= 20 AND t.task_id <= 2400
AND cs <= round(random() * 4 + 1)
LIMIT 8000;


WITH actions AS (
  SELECT unnest(ARRAY[
    'Создана задача',
    'Изменён статус: в работе',
    'Появился комментарий',
    'Поменялся дедлайн',
    'Закрыта',
    'Передана другому исполнителю',
    'Требуется доработка',
    'Баг исправлен',
    'Переведена в тестирование',
    'Переприоритизирована'
  ]) AS action_text
)
INSERT INTO project.task_log (task_id, user_id, action, changed_at)
SELECT
  t.task_id,
  1 + ((lg + t.task_id) % 50),
  act.action_text,
  now() - (lg * interval '1 hour')
FROM project.tasks t,
     LATERAL generate_series(1, 2 + t.task_id % 4) lg,
     actions act
WHERE act.action_text IS NOT NULL AND lg <= round(random()*5+1)
LIMIT 7500;


WITH filetypes AS (
  SELECT unnest(ARRAY['png','jpg','pdf','docx','xlsx']) AS ftype
)
INSERT INTO project.attachments (task_id, filename, file_url, filetype)
SELECT
  t.task_id,
  'attachment_' || t.task_id || '_' || attnum || '.' || ft.ftype,
  'https://fileserver/attachments/attachment_' || t.task_id || '_' || attnum || '.' || ft.ftype,
  ft.ftype
FROM project.tasks t,
     LATERAL generate_series(1, CASE WHEN t.task_id % 7 = 0 THEN 3 WHEN t.task_id % 3 = 0 THEN 2 ELSE 1 END) attnum,
     filetypes ft
WHERE attnum = 1 OR (attnum <= 3 AND t.task_id % 7 = 0)
LIMIT 3500;

INSERT INTO core.users (name, email, password_hash, contact_info)
SELECT
  CASE
    WHEN gs % 5 = 0 THEN 'Alexey Petrov'
    WHEN gs % 5 = 1 THEN 'Marina Sokolova'
    WHEN gs % 5 = 2 THEN 'Ivan Belov'
    WHEN gs % 5 = 3 THEN 'Olga Volkova'
    ELSE 'Sergey Fedorov'
  END || ' ' || gs,
  'user' || gs || '@company.ru',
  'pass' || gs,
  CASE
    WHEN gs % 4 = 0 THEN 'Москва'
    WHEN gs % 4 = 1 THEN 'СПб'
    WHEN gs % 4 = 2 THEN 'Казань'
    ELSE 'Пермь'
  END
FROM generate_series(5, 50) gs;


INSERT INTO analytics.workload_summary (user_id, project_id, open_tasks_count, closed_tasks_count, sprint_id)
SELECT
    u.user_id,
    p.project_id,
    floor(random()*12),
    floor(random()*9),
    s.sprint_id
FROM core.users u, project.projects p, project.sprints s
WHERE s.project_id = p.project_id
  AND u.user_id <= 50
LIMIT 800;

UPDATE project.tasks
SET parent_task_id = CASE
    WHEN task_id % 15 = 0 THEN task_id - 1
    WHEN task_id % 23 = 0 THEN task_id - 2
    ELSE NULL
END
WHERE task_id BETWEEN 3 AND 2400;

TRUNCATE TABLE project.comments;

WITH texts AS (
  SELECT unnest(ARRAY[
    'Сделал, проверьте.',
    'Нужно уточнить детали.',
    'Исправлено, жду отзыв.',
    'Проблема не решена, нужна помощь.',
    'Отправил в тестирование.',
    'Файл приложил выше.',
    'Завтра поправлю.',
    'Переношу задачу на завтра.',
    'Ожидаю ответа от менеджера.',
    'Хочу внести правку.'
  ]) AS ready_text
)
INSERT INTO project.comments (task_id, user_id, text, created_at)
SELECT
  t.task_id,
  1 + ((cs + t.task_id) % 50),
  txt.ready_text,
  now() - (cs * interval '1 hour')
FROM project.tasks t,
LATERAL generate_series(
  1,
  CASE 
    WHEN t.task_id % 10 = 0 THEN 0
    WHEN t.task_id % 3 = 0 THEN 2
    WHEN t.task_id % 2 = 0 THEN 3
    ELSE 1
  END
) AS cs,
texts txt
WHERE cs > 0 AND txt.ready_text IS NOT NULL AND cs <= 3 AND t.task_id <= 2400
LIMIT 2500;

UPDATE core.users
SET password_hash = md5(email || '_good_pass');

INSERT INTO core.users (name, email, password_hash, contact_info)
SELECT
  'User_' || gs,
  'user' || gs || '@company.ru',
  md5('user' || gs || '@company.ru' || '_good_pass'),
  CASE WHEN gs % 4 = 0 THEN 'Москва'
       WHEN gs % 4 = 1 THEN 'СПб'
       WHEN gs % 4 = 2 THEN 'Казань'
       ELSE 'Пермь'
  END
FROM generate_series(5, 50) gs
ON CONFLICT (email) DO NOTHING;

UPDATE core.users
SET name = n.fullname, contact_info = n.city
FROM (
  VALUES
    (1, 'Иван Сергеев', 'Москва'),
    (2, 'Мария Кузнецова', 'Санкт-Петербург'),
    (3, 'Андрей Лебедев', 'Екатеринбург'),
    (4, 'Ольга Морозова', 'Новосибирск'),
    (5, 'Дмитрий Павлов', 'Казань'),
    (6, 'Екатерина Васильева', 'Ростов-на-Дону'),
    (7, 'Максим Попов', 'Челябинск'),
    (8, 'Виктория Сидорова', 'Уфа'),
    (9, 'Юлия Макарова', 'Воронеж'),
    (10, 'Алексей Фомин', 'Самара'),
    (11, 'Татьяна Белова', 'Пермь'),
    (12, 'Николай Захаров', 'Красноярск'),
    (13, 'Денис Козлов', 'Иркутск'),
    (14, 'Светлана Гаврилова', 'Омск'),
    (15, 'Артём Романов', 'Томск'),
    (16, 'Полина Аникина', 'Саратов'),
    (17, 'Владимир Гусев', 'Тула'),
    (18, 'Ирина Давыдова', 'Ярославль'),
    (19, 'Александр Панин', 'Севастополь'),
    (20, 'Наталья Воробьева', 'Краснодар'),
    (21, 'Георгий Грачёв', 'Москва'),
    (22, 'Людмила Рябова', 'Краснодар'),
    (23, 'Игорь Тимофеев', 'Новосибирск'),
    (24, 'Олеся Майорова', 'Челябинск'),
    (25, 'Ренат Салихов', 'Екатеринбург'),
    (26, 'Алёна Якушева', 'Пермь'),
    (27, 'Даниил Котов', 'Казань'),
    (28, 'Елизавета Карпова', 'Ижевск'),
    (29, 'Глеб Коновалов', 'Москва'),
    (30, 'Анастасия Орлова', 'Владивосток'),
    (31, 'Павел Суханов', 'Волгоград'),
    (32, 'Зоя Мороз', 'Тверь'),
    (33, 'Егор Данилов', 'Калуга'),
    (34, 'Вячеслав Юров', 'Новокузнецк'),
    (35, 'Софья Федосеева', 'Томск'),
    (36, 'Кирилл Николаев', 'Краснодар'),
    (37, 'Галина Чернова', 'Уфа'),
    (38, 'Тимофей Веснин', 'Сургут'),
    (39, 'Анна Громова', 'Курск'),
    (40, 'Степан Ершов', 'Москва'),
    (41, 'Арина Шмелева', 'Кострома'),
    (42, 'Матвей Павлюк', 'Барнаул'),
    (43, 'Дарья Симонова', 'Калининград'),
    (44, 'Михаил Логинов', 'Белгород'),
    (45, 'Валерия Королёва', 'Белгород'),
    (46, 'Григорий Сазонов', 'Иркутск'),
    (47, 'Оксана Серебрякова', 'Новосибирск'),
    (48, 'Нина Савченко', 'Сочи'),
    (49, 'Виталий Петров', 'Новосибирск'),
    (50, 'Маргарита Ларионова', 'Санкт-Петербург')
) AS n(user_id, fullname, city)
WHERE core.users.user_id = n.user_id;

INSERT INTO core.user_roles (user_id, role_id) VALUES (2, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (3, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (4, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (5, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (6, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (7, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (8, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (9, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (10, 2);
INSERT INTO core.user_roles (user_id, role_id) VALUES (11, 2);

INSERT INTO core.user_roles (user_id, role_id) VALUES (12, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (13, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (14, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (15, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (16, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (17, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (18, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (19, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (20, 3);
INSERT INTO core.user_roles (user_id, role_id) VALUES (21, 3);

INSERT INTO core.user_roles (user_id, role_id) VALUES (21, 3);


-- ====== ИНДЕКСЫ ======
-- индексы для project
CREATE INDEX IF NOT EXISTS idx_projects_manager_id
    ON project.projects (manager_id);

CREATE INDEX IF NOT EXISTS idx_sprints_project_id
    ON project.sprints (project_id);

CREATE INDEX IF NOT EXISTS idx_tasks_project_id
    ON project.tasks (project_id);

CREATE INDEX IF NOT EXISTS idx_tasks_sprint_id
    ON project.tasks (sprint_id);

CREATE INDEX IF NOT EXISTS idx_tasks_user_id
    ON project.tasks (user_id);

CREATE INDEX IF NOT EXISTS idx_tasks_status
    ON project.tasks (status);

CREATE INDEX IF NOT EXISTS idx_task_assignments_task_id
    ON project.task_assignments (task_id);

CREATE INDEX IF NOT EXISTS idx_task_assignments_user_id
    ON project.task_assignments (user_id);

CREATE INDEX IF NOT EXISTS idx_comments_task_id
    ON project.comments (task_id);

CREATE INDEX IF NOT EXISTS idx_comments_user_id
    ON project.comments (user_id);

CREATE INDEX IF NOT EXISTS idx_attachments_task_id
    ON project.attachments (task_id);

CREATE INDEX IF NOT EXISTS idx_task_log_task_id
    ON project.task_log (task_id);

CREATE INDEX IF NOT EXISTS idx_task_log_user_id
    ON project.task_log (user_id);

-- индексы для core
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id
    ON core.user_roles (user_id);

CREATE INDEX IF NOT EXISTS idx_user_roles_role_id
    ON core.user_roles (role_id);

CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id
    ON core.role_permissions (role_id);

CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id
    ON core.role_permissions (permission_id);

-- индексы для analytics
CREATE INDEX IF NOT EXISTS idx_workload_user_id
    ON analytics.workload_summary (user_id);

CREATE INDEX IF NOT EXISTS idx_workload_project_id
    ON analytics.workload_summary (project_id);

CREATE INDEX IF NOT EXISTS idx_workload_sprint_id
    ON analytics.workload_summary (sprint_id);


--================= 2 часть ==============================
-- ===== РОЛИ =====
-- роли
CREATE ROLE app_admin NOINHERIT;
CREATE ROLE project_manager NOINHERIT;
CREATE ROLE developer_user NOINHERIT;

-- логин-пользователи
CREATE ROLE user_admin LOGIN PASSWORD 'admadm123';
CREATE ROLE user_pm    LOGIN PASSWORD 'pmpmpm123';
CREATE ROLE user_dev1  LOGIN PASSWORD 'devdev123';
CREATE ROLE user_dev2  LOGIN PASSWORD 'devved123';

GRANT app_admin       TO user_admin;
GRANT project_manager TO user_pm;
GRANT developer_user  TO user_dev1;
GRANT developer_user  TO user_dev2;

-- схемы
GRANT USAGE ON SCHEMA core, project, analytics
TO app_admin, project_manager, developer_user;

GRANT CREATE ON SCHEMA core, project, analytics TO app_admin;

-- core
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA core
TO app_admin;

GRANT SELECT
ON ALL TABLES IN SCHEMA core
TO project_manager;

GRANT SELECT
ON core.users
TO developer_user;

REVOKE ALL ON core.roles, core.permissions, core.user_roles, core.role_permissions
FROM developer_user;

-- project
GRANT SELECT, INSERT, UPDATE, DELETE
ON project.projects,
   project.sprints,
   project.tasks,
   project.comments,
   project.attachments,
   project.task_log,
   project.task_assignments
TO app_admin, project_manager;

GRANT SELECT
ON project.projects,
   project.sprints,
   project.tasks,
   project.comments,
   project.attachments,
   project.task_log
TO developer_user;

GRANT INSERT
ON project.comments,
   project.attachments
TO developer_user;

-- analytics
GRANT SELECT, INSERT, UPDATE, DELETE
ON analytics.workload_summary
TO app_admin, project_manager;

GRANT SELECT
ON analytics.workload_summary
TO developer_user;

-- default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA core
   GRANT SELECT ON TABLES TO project_manager, developer_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA project
   GRANT SELECT ON TABLES TO project_manager, developer_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA project
   GRANT INSERT, UPDATE, DELETE ON TABLES TO app_admin, project_manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
   GRANT SELECT ON TABLES TO project_manager, developer_user;


-- ===== VIEW: детализированный список задач =====
CREATE VIEW project.v_task_details AS
SELECT
    t.task_id,
    t.name           AS task_name,
    t.description    AS task_description,
    t.status,
    t.priority,
    t.created_at,
    t.updated_at,
    t.deadline,
    p.project_id,
    p.name           AS project_name,
    s.sprint_id,
    s.name           AS sprint_name,
    u.user_id,
    u.name           AS user_name
FROM project.tasks      t
LEFT JOIN project.projects p ON p.project_id = t.project_id
LEFT JOIN project.sprints s ON s.sprint_id = t.sprint_id
LEFT JOIN core.users u ON u.user_id  = t.user_id;

COMMENT ON VIEW project.v_task_details IS 'Расширенное представление по задачам с проектом, спринтом и исполнителем';

-- Оконная функция (ранжирование пользователей по количеству открытых задач)
CREATE OR REPLACE VIEW analytics.v_user_rank_by_open_tasks AS
SELECT
    user_id,
    project_id,
    open_tasks_count,
    RANK() OVER (PARTITION BY project_id ORDER BY open_tasks_count DESC) AS open_rank
FROM analytics.workload_summary;
COMMENT ON VIEW analytics.v_user_rank_by_open_tasks IS
'Аналитическое представление с ранком пользователя по количеству открытых задач в проекте';
SELECT *
FROM analytics.v_user_rank_by_open_tasks
ORDER BY project_id, open_rank
LIMIT 50;

-- ===== MATERIALIZED VIEW: агрегированная нагрузка по пользователям =====
CREATE MATERIALIZED VIEW analytics.mv_user_workload AS
SELECT
    u.user_id,
    u.name                           AS user_name,
    p.project_id,
    p.name                           AS project_name,
    COUNT(*) FILTER (WHERE t.status IN ('новая','в работе', 'тест'))  AS open_tasks,
    COUNT(*) FILTER (WHERE t.status IN ('готова','отложена'))      AS closed_tasks,
    MAX(t.updated_at)                AS last_activity_at
FROM core.users        u
JOIN project.tasks     t ON t.user_id = u.user_id
JOIN project.projects  p ON p.project_id = t.project_id
GROUP BY u.user_id, u.name, p.project_id, p.name
WITH NO DATA;

COMMENT ON MATERIALIZED VIEW analytics.mv_user_workload IS 'Агрегированная нагрузка по задачам на пользователей и проекты';

CREATE INDEX IF NOT EXISTS idx_mv_user_workload_user
    ON analytics.mv_user_workload (user_id);

CREATE INDEX IF NOT EXISTS idx_mv_user_workload_project
    ON analytics.mv_user_workload (project_id);

-- ===== ФУНКЦИЯ ДЛЯ ОБНОВЛЕНИЯ MAT VIEW =====
CREATE FUNCTION analytics.refresh_mv_user_workload()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics.mv_user_workload;
END;
$$;

COMMENT ON FUNCTION analytics.refresh_mv_user_workload() IS 'Обновление материализованного представления по нагрузке пользователей';
COMMENT ON VIEW project.v_task_details IS 'Представление для запросов бэкенда и отчётов по задачам';
COMMENT ON MATERIALIZED VIEW analytics.mv_user_workload IS 'Материализованная витрина нагрузки по пользователям и проектам';

-- Тестим вью
SELECT * 
FROM project.v_task_details
LIMIT 20;


SELECT analytics.refresh_mv_user_workload();
SELECT *
FROM analytics.mv_user_workload
LIMIT 20;

-- ========== ТРИГГЕРЫ =========
-- Изменение статуса задачи и запись в тасклог
-- функция-триггер
CREATE OR REPLACE FUNCTION project.fn_task_status_log()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'UPDATE'
       AND NEW.status IS DISTINCT FROM OLD.status
    THEN
        INSERT INTO project.task_log (task_id, user_id, action, changed_at)
        VALUES (
            NEW.task_id,
            NEW.user_id,
            'status_change: ' || COALESCE(OLD.status, 'NULL') || ' -> ' || COALESCE(NEW.status, 'NULL'),
            now()
        );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_task_status_log ON project.tasks;

CREATE TRIGGER trg_task_status_log
AFTER UPDATE ON project.tasks
FOR EACH ROW
EXECUTE FUNCTION project.fn_task_status_log();


-- триггер на таблицу задач
CREATE TRIGGER trg_task_status_log
AFTER UPDATE ON project.tasks
FOR EACH ROW
EXECUTE FUNCTION project.fn_task_status_log();
-- тестим
UPDATE project.tasks
SET status = 'в работе'
WHERE task_id = 42;

SELECT *
FROM project.task_log
WHERE task_id = 42
ORDER BY changed_at DESC
LIMIT 5;


--======= ПРОЦЕДУРЫ И ФУНКЦИИ ==========
-- Функция: задачи пользователя
CREATE OR REPLACE FUNCTION project.fn_get_user_tasks(
    p_user_id  integer,
    p_status   text DEFAULT NULL
)
RETURNS TABLE (
    task_id      integer,
    task_name    text,
    status       text,
    priority     text,
    project_id   integer,
    project_name text,
    sprint_id    integer,
    sprint_name  text
)
LANGUAGE sql
AS $$
SELECT
    t.task_id,
    t.name,
    t.status,
    t.priority,
    p.project_id,
    p.name,
    s.sprint_id,
    s.name
FROM project.tasks   t
JOIN project.projects p ON p.project_id = t.project_id
LEFT JOIN project.sprints s ON s.sprint_id = t.sprint_id
WHERE t.user_id = p_user_id
  AND (p_status IS NULL OR t.status = p_status);
$$;

-- Функция: нагрузка по пользователю
CREATE OR REPLACE FUNCTION analytics.fn_get_user_workload(
    p_user_id integer
)
RETURNS TABLE (
    project_id    integer,
    project_name  text,
    open_tasks    integer,
    closed_tasks  integer
)
LANGUAGE sql
AS $$
SELECT
    p.project_id,
    p.name,
    COUNT(*) FILTER (WHERE t.status IN ('новая','в работе')) AS open_tasks,
    COUNT(*) FILTER (WHERE t.status IN ('сделана','закрыта')) AS closed_tasks
FROM project.tasks   t
JOIN project.projects p ON p.project_id = t.project_id
WHERE t.user_id = p_user_id
GROUP BY p.project_id, p.name;
$$;

-- Процедура: создать задачу + лог
CREATE OR REPLACE PROCEDURE project.sp_create_task(
    p_name        text,
    p_description text,
    p_priority    text,
    p_status      text,
    p_project_id  integer,
    p_sprint_id   integer,
    p_user_id     integer,
    p_deadline    timestamptz
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_task_id integer;
BEGIN
    INSERT INTO project.tasks (
        name, description, priority, status,
        created_at, updated_at, deadline,
        project_id, sprint_id, user_id
    )
    VALUES (
        p_name, p_description, p_priority, p_status,
        now(), now(), p_deadline,
        p_project_id, p_sprint_id, p_user_id
    )
    RETURNING task_id INTO v_task_id;

    INSERT INTO project.task_log (task_id, user_id, action, changed_at)
    VALUES (v_task_id, p_user_id, 'created', now());
END;
$$;


--Процедура: закрыть задачу + лог
CREATE OR REPLACE PROCEDURE project.sp_close_task(
    p_task_id integer,
    p_user_id integer,
    p_new_status text DEFAULT 'сделана'
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE project.tasks
    SET status = p_new_status,
        updated_at = now()
    WHERE task_id = p_task_id;

    INSERT INTO project.task_log (task_id, user_id, action, changed_at)
    VALUES (p_task_id, p_user_id, 'closed_to: ' || p_new_status, now());
END;
$$;

-- тестим
CALL project.sp_create_task('Тестовая задача', 'описание', 'высокий', 'новая', 1, 1, 10, now() + interval '7 days');
CALL project.sp_close_task(42, 10, 'готова');

SELECT * FROM project.fn_get_user_tasks(1, 'в работе');
SELECT * FROM analytics.fn_get_user_workload(10);

SELECT *
FROM analytics.fn_get_user_workload(21);


-- ============ Рекурсивные запросы ==========
CREATE OR REPLACE VIEW project.v_task_tree AS
WITH RECURSIVE task_tree AS (
    -- корень: задачи без родителя
    SELECT
        t.task_id,
        t.name,
        t.parent_task_id,
        t.project_id,
        1          AS level,
        t.name::text AS path
    FROM project.tasks t
    WHERE t.parent_task_id IS NULL

    UNION ALL

    -- рекурсивная часть: подзадачи
    SELECT
        c.task_id,
        c.name,
        c.parent_task_id,
        c.project_id,
        p.level + 1 AS level,
        (p.path || ' / ' || c.name)::text AS path
    FROM project.tasks c
    JOIN task_tree p ON c.parent_task_id = p.task_id
)
SELECT
    task_id,
    name,
    parent_task_id,
    project_id,
    level,
    path
FROM task_tree;

-- тестим
SELECT *
FROM project.v_task_tree
ORDER BY project_id, path;

WITH RECURSIVE task_tree AS (
    SELECT
        t.task_id,
        t.name,
        t.parent_task_id,
        t.project_id,
        1 AS level,
        t.name::text AS path
    FROM project.tasks t
    WHERE t.task_id = 59

    UNION ALL

    SELECT
        c.task_id,
        c.name,
        c.parent_task_id,
        c.project_id,
        p.level + 1,
        (p.path || ' / ' || c.name)::text
    FROM project.tasks c
    JOIN task_tree p ON c.parent_task_id = p.task_id
)
SELECT *
FROM task_tree
ORDER BY level, task_id;
