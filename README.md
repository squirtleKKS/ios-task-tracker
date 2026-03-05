# Architecture

В приложении используется архитектура **MVVM (Model–View–ViewModel)** с выделением слоев **Domain, Data, Services и Presentation**.

- **Domain** содержит доменные сущности и value objects, которые описывают предметную область (Task, Reminder, Statistics и др.).
- **Data** определяет интерфейсы доступа к данным (Repositories, SessionStore).
- **Services** реализуют бизнес-операции приложения и используют репозитории для получения данных.
- **Presentation** реализует слой UI по паттерну MVVM. View отображает состояние, ViewModel содержит логику экрана, а Router отвечает за навигацию.
- Взаимодействие между слоями происходит через **протоколы**, что упрощает тестирование и подмену зависимостей моками.

Такая архитектура обеспечивает **разделение ответственности, тестируемость и масштабируемость** приложения.

---

# Modules

Приложение состоит из следующих модулей (по одному на экран):

## Auth

Отвечает за авторизацию пользователя. Выполняет вход и при успешной авторизации открывает экран списка возможностей.

## Features

Отображает список доступных возможностей приложения (Tasks, Statistics, Reminders) и выполняет навигацию к соответствующим экранам.

## Tasks

Отвечает за отображение списка задач, создание, удаление и фильтрацию задач.

## Statistics

Отображает статистику по задачам за выбранный период.

## Reminders

Отвечает за управление напоминаниями для задач (создание, включение/выключение, удаление).

---

# Screens

## Auth Screen

### Вход
- email пользователя
- password пользователя

### Выход
- успешная авторизация → переход к экрану Features
- ошибка авторизации

### UI состояния
- initial
- loading
- error
- content

### Сценарии
- пользователь вводит email и пароль
- пользователь нажимает Login
- ViewModel вызывает AuthService
- при успехе Router открывает Features экран
- при ошибке отображается сообщение

---

## Features Screen

### Вход
- текущая пользовательская сессия

### Выход
- переход к Tasks
- переход к Statistics
- переход к Reminders
- выход из аккаунта

### UI состояния
- loading
- content
- error

### Сценарии
- экран загружается
- ViewModel получает список доступных фич
- пользователь выбирает фичу
- Router открывает соответствующий экран

---

## Tasks Screen

### Вход
- фильтр задач (TasksFilter)
- сортировка задач (TasksSort)

### Выход
- создание задачи
- удаление задачи
- изменение фильтра
- обновление списка задач

### UI состояния
- loading
- content
- empty
- error

### Сценарии
- экран открывается
- ViewModel запрашивает задачи через TasksService
- данные преобразуются в TaskItemVM
- View отображает список задач
- пользователь может удалить или создать задачу

---

## Statistics Screen

### Вход
- период статистики (StatsPeriod)

### Выход
- изменение периода
- обновление статистики

### UI состояния
- loading
- content
- error

### Сценарии
- экран открывается
- ViewModel запрашивает статистику через StatisticsService
- View отображает агрегированные данные

---

## Reminders Screen

### Вход
- taskId (опционально)

### Выход
- создание напоминания
- включение/выключение напоминания
- удаление напоминания

### UI состояния
- loading
- content
- empty
- error

### Сценарии
- экран открывается
- ViewModel получает список напоминаний через RemindersService
- пользователь может создать или удалить напоминание

---

# Key Protocols

## Presentation
- AuthView
- AuthViewModel
- AuthRouter
- FeaturesView
- FeaturesViewModel
- FeaturesRouter
- TasksView
- TasksViewModel
- TasksRouter
- StatisticsView
- StatisticsViewModel
- StatisticsRouter
- RemindersView
- RemindersViewModel
- RemindersRouter

## Services
- AuthService
- TasksService
- StatisticsService
- RemindersService
- FeaturesService

## Data
- AuthRepository
- TasksRepository
- StatisticsRepository
- RemindersRepository
- SessionStore

---

# Key Models

## Domain
- Task
- TaskID
- TaskPriority
- TaskStatus
- TasksFilter
- TasksSort
- TaskReminder
- ReminderID
- ReminderSchedule
- Weekday
- TasksStats
- StatsPeriod
- User
- UserSession
- AppFeature
- FeatureID
- AppFeatureKind
- DomainError

## Presentation
- AuthViewState
- FeaturesViewState
- TasksViewState
- StatisticsViewState
- RemindersViewState
- LoadableState