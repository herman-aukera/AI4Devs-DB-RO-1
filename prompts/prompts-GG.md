# Prompt para Expansión de Base de Datos ATS - Migración Completa de Entidades

## Contexto del Proyecto

Soy desarrollador senior trabajando en un **ATS (Applicant Tracking System)** construido con:
- **Backend**: Express.js + Prisma + PostgreSQL
- **Frontend**: React + TypeScript  
- **Arquitectura**: Clean Architecture (Domain, Application, Presentation)

## Estado Actual vs Estado Deseado

**ESTADO ACTUAL**: La base de datos solo maneja candidatos básicos con educación, experiencia laboral y CVs.

**ESTADO DESEADO**: Sistema completo de gestión de candidatos que incluya empresas, posiciones, flujos de entrevistas y aplicaciones.

## Diagrama ERD a Implementar

```mermaid
erDiagram
     COMPANY {
         int id PK
         string name
     }
     EMPLOYEE {
         int id PK
         int company_id FK
         string name
         string email
         string role
         boolean is_active
     }
     POSITION {
         int id PK
         int company_id FK
         int interview_flow_id FK
         string title
         text description
         string status
         boolean is_visible
         string location
         text job_description
         text requirements
         text responsibilities
         numeric salary_min
         numeric salary_max
         string employment_type
         text benefits
         text company_description
         date application_deadline
         string contact_info
     }
     INTERVIEW_FLOW {
         int id PK
         string description
     }
     INTERVIEW_STEP {
         int id PK
         int interview_flow_id FK
         int interview_type_id FK
         string name
         int order_index
     }
     INTERVIEW_TYPE {
         int id PK
         string name
         text description
     }
     CANDIDATE {
         int id PK
         string firstName
         string lastName
         string email
         string phone
         string address
     }
     APPLICATION {
         int id PK
         int position_id FK
         int candidate_id FK
         date application_date
         string status
         text notes
     }
     INTERVIEW {
         int id PK
         int application_id FK
         int interview_step_id FK
         int employee_id FK
         date interview_date
         string result
         int score
         text notes
     }

     COMPANY ||--o{ EMPLOYEE : employs
     COMPANY ||--o{ POSITION : offers
     POSITION ||--|| INTERVIEW_FLOW : assigns
     INTERVIEW_FLOW ||--o{ INTERVIEW_STEP : contains
     INTERVIEW_STEP ||--|| INTERVIEW_TYPE : uses
     POSITION ||--o{ APPLICATION : receives
     CANDIDATE ||--o{ APPLICATION : submits
     APPLICATION ||--o{ INTERVIEW : has
     INTERVIEW ||--|| INTERVIEW_STEP : consists_of
     EMPLOYEE ||--o{ INTERVIEW : conducts
```

## Tareas Específicas Requeridas

### 1. **Análisis del Schema Actual**
- Examina el archivo schema.prisma actual
- Identifica qué entidades ya existen (Candidate, Education, WorkExperience, Resume)
- Determina qué campos pueden reutilizarse vs. necesitar modificaciones

### 2. **Creación del Schema Prisma Expandido**
Actualiza `schema.prisma` con:

**REQUISITOS TÉCNICOS OBLIGATORIOS**:
- Mantener compatibilidad con la estructura actual de `Candidate`
- Aplicar **normalización de base de datos** (3FN mínimo)
- Definir **índices apropiados** para optimización de consultas
- Usar **tipos de datos adecuados** según Prisma + PostgreSQL
- Implementar **relaciones bidireccionales** correctas
- Agregar **constraints** de integridad referencial
- Incluir **campos de auditoría** (createdAt, updatedAt) donde sea apropiado

**VALIDACIONES DE NEGOCIO**:
- Emails únicos en Employees y Candidates
- Status con valores predefinidos (ENUM)
- Rangos salariales lógicos (min <= max)
- Fechas de deadline futuras
- Scores de entrevista en rango válido (0-100)

### 3. **Generación de Migración SQL**
- Crear migración Prisma que transforme la DB actual al nuevo schema
- La migración debe ser **no destructiva** (preservar datos existentes)
- Incluir **nombres descriptivos** para constraints e índices
- Agregar **comentarios SQL** explicando cambios complejos

### 4. **Índices de Optimización**
Crear índices estratégicos para:
- Búsquedas frecuentes (email, status, fechas)
- Joins complejos entre entidades relacionadas
- Campos de filtrado común (company_id, position_id, etc.)

### 5. **Consideraciones de Rendimiento**
- Evaluar cardinalidad de relaciones
- Proponer **desnormalización selectiva** si es beneficiosa
- Considerar **particionado** para tablas grandes (Applications, Interviews)

## Criterios de Éxito

1. **Funcionalidad**: El schema debe soportar el flujo completo: Empresa → Posición → Aplicación → Entrevistas
2. **Performance**: Consultas comunes deben ejecutar en <100ms con 10K registros
3. **Integridad**: Imposible crear datos inconsistentes via constraints
4. **Escalabilidad**: Estructura preparada para 100K+ candidatos y aplicaciones
5. **Mantenibilidad**: Código Prisma limpio, bien documentado y seguir convenciones

## Restricciones Importantes

- **NO romper** funcionalidad existente del sistema actual
- **NO eliminar** tablas o campos existentes sin migración de datos
- **SÍ usar** nombres en inglés para consistencia
- **SÍ seguir** convenciones de naming de Prisma (camelCase en modelos, snake_case en DB)
- **SÍ incluir** validaciones a nivel de schema cuando sea posible

## Entregables Finales

1. `schema.prisma` completamente actualizado y funcional
2. Archivo de migración SQL ejecutable
3. Documentación de decisiones de diseño en comentarios
4. Script de validación/testing opcional para verificar integridad
