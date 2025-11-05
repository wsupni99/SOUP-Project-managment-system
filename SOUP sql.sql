-- Tablespaces
CREATE TABLESPACE user_data_space OWNER postgres LOCATION 'C:/PostgresTablespace/user_data';
CREATE TABLESPACE index_space OWNER postgres LOCATION 'C:/PostgresTablespace/index_data';

-- Перенос на tablespace (раньше было без них)
ALTER TABLE project.projects SET TABLESPACE user_data_space;
ALTER TABLE project.sprints SET TABLESPACE user_data_space;
ALTER TABLE project.tasks SET TABLESPACE user_data_space;
ALTER TABLE project.task_assignments SET TABLESPACE user_data_space;
ALTER TABLE project.comments SET TABLESPACE user_data_space;
ALTER TABLE project.attachments SET TABLESPACE user_data_space;
ALTER TABLE project.task_log SET TABLESPACE user_data_space;

ALTER TABLE core.roles SET TABLESPACE user_data_space;
ALTER TABLE core.permissions SET TABLESPACE user_data_space;
ALTER TABLE core.users SET TABLESPACE user_data_space;
ALTER TABLE core.user_roles SET TABLESPACE user_data_space;
ALTER TABLE core.role_permissions SET TABLESPACE user_data_space;

ALTER TABLE analytics.workload_summary SET TABLESPACE user_data_space;

-- Индексы
CREATE INDEX idx_tasks_project_id ON project.tasks(project_id) TABLESPACE index_space;
CREATE INDEX idx_tasks_status ON project.tasks(status) TABLESPACE index_space;
CREATE INDEX idx_tasks_sprint_id ON project.tasks(sprint_id) TABLESPACE index_space;
CREATE INDEX idx_projects_manager_id ON project.projects(manager_id) TABLESPACE index_space;
CREATE INDEX idx_task_assignments_user_id ON project.task_assignments(user_id) TABLESPACE index_space;
CREATE INDEX idx_comments_task_id ON project.comments(task_id) TABLESPACE index_space;

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

-- Комментарии к таблицам и столбцам
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

-- НАПОЛНЕНИЕ ДАННЫМИ (тестовые)
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

-- Реалистичные примерные шаблоны комментариев
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


