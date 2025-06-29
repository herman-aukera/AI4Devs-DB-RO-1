# Prisma Database Schema and Migrations

This directory contains the database schema definition and migration files for the ATS (Applicant Tracking System).

## Files Overview

### Core Schema
- **`schema.prisma`** - Main Prisma schema file defining all models, relations, and database configuration
- **`DESIGN_DECISIONS.md`** - Detailed documentation of design decisions and implementation notes

### Migration Files
- **`migrations/20250629143000_expand_ats_schema/migration.sql`** - Complete migration from basic candidate system to full ATS functionality

### Utility Scripts
- **`sample_data.sql`** - Sample data for testing the ATS system
- **`validate_schema.sql`** - Validation script to verify schema integrity after migration

## Migration Details

### What This Migration Does

#### 🆕 **New Tables Created**
- `companies` - Multi-tenant company support
- `employees` - Company staff who manage hiring
- `positions` - Job openings/postings
- `interview_flows` - Interview process templates
- `interview_steps` - Individual steps in interview flows
- `interview_types` - Reusable interview types (phone, technical, etc.)
- `applications` - Candidate applications to positions
- `interviews` - Individual interview sessions

#### 🔄 **Existing Tables Modified**
- `Candidate` → `candidates` (renamed, added audit fields)
- `Education` → `educations` (renamed, column names normalized)
- `WorkExperience` → `work_experiences` (renamed, column names normalized)
- `Resume` → `resumes` (renamed, added metadata fields)

#### 📊 **ENUMs Added**
- `position_status` - Job position statuses
- `employment_type` - Full-time, part-time, contract, etc.
- `application_status` - Application workflow states
- `interview_result` - Interview outcomes
- `employee_role` - HR roles and permissions

### Migration Safety

✅ **Non-destructive** - No existing data is lost
✅ **Backwards compatible** - Existing functionality preserved
✅ **Additive** - Only adds new structures and relationships
✅ **Constraint-safe** - New foreign keys added safely

## Running the Migration

### Prerequisites
1. PostgreSQL database running
2. Prisma CLI installed
3. Database connection configured in `.env`

### Steps
```bash
# Navigate to backend directory
cd backend

# Generate Prisma client (updates types)
npx prisma generate

# Run migration (when database is ready)
npx prisma migrate deploy

# Optional: Load sample data
psql -d your_database -f prisma/sample_data.sql

# Optional: Validate schema
psql -d your_database -f prisma/validate_schema.sql
```

## Database Relationships

```
Company (1:N) Employee
Company (1:N) Position
Position (N:1) InterviewFlow
InterviewFlow (1:N) InterviewStep
InterviewStep (N:1) InterviewType
Position (1:N) Application
Candidate (1:N) Application
Application (1:N) Interview
Interview (N:1) InterviewStep
Interview (N:1) Employee
```

## Key Features

### 🏢 **Multi-tenancy**
- Company-based data isolation
- Employee access control by company
- Scalable for multiple organizations

### 🔄 **Flexible Interview Process**
- Reusable interview flow templates
- Configurable interview steps and types
- Ordered interview sequences

### 📊 **Complete Application Tracking**
- Full candidate-to-hire pipeline
- Status tracking at every step
- Interview results and feedback

### ⚡ **Performance Optimized**
- Strategic indexes on frequently queried columns
- Efficient foreign key relationships
- Prepared for high-volume operations

## Testing

### Schema Validation
```bash
psql -d your_database -f prisma/validate_schema.sql
```

### Sample Data Loading
```bash
psql -d your_database -f prisma/sample_data.sql
```

### Common Queries
```sql
-- List all active positions by company
SELECT c.name as company, p.title, p.status 
FROM companies c 
JOIN positions p ON c.id = p.company_id 
WHERE p.status = 'PUBLISHED';

-- Application pipeline summary
SELECT 
    p.title as position,
    a.status,
    COUNT(*) as applications
FROM positions p
JOIN applications a ON p.id = a.position_id
GROUP BY p.id, p.title, a.status
ORDER BY p.title, a.status;
```

## Next Steps

After running this migration:

1. **Update Prisma Client**: Run `npx prisma generate`
2. **Update Domain Models**: Create new domain model classes
3. **Create Services**: Implement business logic for new entities
4. **Update Controllers**: Add API endpoints for new functionality
5. **Frontend Integration**: Update React components for new features

## Troubleshooting

### Common Issues

**Database Connection Errors**
- Verify `DATABASE_URL` in `.env` file
- Ensure PostgreSQL is running
- Check database credentials

**Migration Conflicts**
- Run `npx prisma migrate status` to check migration state
- Use `npx prisma migrate resolve` for failed migrations

**Schema Validation Failures**
- Check `validate_schema.sql` output for specific issues
- Verify all ENUMs and constraints are created
- Ensure foreign key relationships are properly established

### Support

For migration issues or questions:
1. Check the `DESIGN_DECISIONS.md` for implementation details
2. Review the migration SQL for specific changes
3. Use the validation script to identify problems
4. Consult Prisma documentation for migration troubleshooting
