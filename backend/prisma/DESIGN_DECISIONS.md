# ATS Database Schema - Design Decisions and Implementation Notes

## Overview
This document explains the design decisions made during the expansion of the ATS (Applicant Tracking System) database schema from a simple candidate management system to a full-featured ATS platform.

## Architecture Decisions

### 1. **Clean Architecture Compliance**
- **Domain Models**: Each entity represents a clear business concept
- **Separation of Concerns**: Business logic separated from data access
- **Dependency Direction**: Domain entities don't depend on external frameworks

### 2. **Database Design Principles Applied**

#### **Normalization (3NF)**
- **Companies** are normalized to avoid data duplication across positions
- **Interview Types** are separate entities to allow reuse across different flows
- **Interview Steps** link flows and types, enabling flexible interview process configuration
- **ENUMs** are used for constrained values to ensure data integrity

#### **Referential Integrity**
- **CASCADE DELETE**: When a company is deleted, all related employees and positions are removed
- **CASCADE DELETE**: When a candidate is deleted, all applications and related data are removed
- **RESTRICT DELETE**: Interview types and steps cannot be deleted if they're being used
- **SET NULL**: If an interview flow is deleted, positions don't fail but lose their flow reference

### 3. **Performance Optimization**

#### **Strategic Indexing**
```sql
-- Frequently searched columns
CREATE INDEX "candidates_email_idx" ON "candidates"("email");
CREATE INDEX "positions_status_idx" ON "positions"("status");

-- Compound indexes for common queries
CREATE INDEX "candidates_lastName_firstName_idx" ON "candidates"("lastName", "firstName");

-- Foreign key indexes for JOIN performance
CREATE INDEX "applications_position_id_idx" ON "applications"("position_id");
CREATE INDEX "applications_candidate_id_idx" ON "applications"("candidate_id");
```

#### **Query Optimization Considerations**
- **Position Searches**: Indexed by status, location, employment_type for job board queries
- **Application Tracking**: Indexed by status and date for dashboard views
- **Interview Scheduling**: Indexed by date and result for calendar integration

### 4. **Data Integrity & Business Rules**

#### **ENUM Types for Consistency**
```sql
-- Prevents invalid status values
CREATE TYPE "application_status" AS ENUM (
    'SUBMITTED', 'UNDER_REVIEW', 'INTERVIEW_SCHEDULED', 
    'INTERVIEWED', 'OFFER_EXTENDED', 'OFFER_ACCEPTED', 
    'OFFER_DECLINED', 'REJECTED', 'WITHDRAWN'
);
```

#### **Unique Constraints for Business Logic**
```sql
-- Prevents duplicate applications
ALTER TABLE "applications" ADD CONSTRAINT "applications_position_id_candidate_id_key" 
UNIQUE ("position_id", "candidate_id");

-- Ensures ordered interview steps within flows
ALTER TABLE "interview_steps" ADD CONSTRAINT "interview_steps_interview_flow_id_order_index_key" 
UNIQUE ("interview_flow_id", "order_index");
```

### 5. **Backwards Compatibility**

#### **Preserved Existing Structure**
- Original `Candidate`, `Education`, `WorkExperience`, and `Resume` structures maintained
- Added audit fields (`created_at`, `updated_at`) without breaking existing functionality
- Column renames use snake_case for database consistency while preserving relationships

#### **Migration Safety**
- **Non-destructive**: No existing data is lost during migration
- **Additive**: New tables and columns are added without modifying existing data
- **Constraint-safe**: New foreign keys added only after tables are created

### 6. **Scalability Decisions**

#### **Multi-tenancy Support**
- **Company-based isolation**: All major entities link to companies
- **Employee-based access control**: Employees belong to companies and conduct interviews
- **Data partitioning ready**: Structure supports future partitioning by company_id

#### **Performance at Scale**
```sql
-- Optimized for common query patterns
CREATE INDEX "applications_application_date_idx" ON "applications"("application_date");
CREATE INDEX "interviews_interview_date_idx" ON "interviews"("interview_date");
CREATE INDEX "positions_application_deadline_idx" ON "positions"("application_deadline");
```

## Entity Relationships Explained

### **Core Business Flow**
1. **Company** creates **Positions** with **Interview Flows**
2. **Candidates** submit **Applications** to **Positions**  
3. **Employees** conduct **Interviews** following **Interview Steps**
4. **Interview Results** determine application progression

### **Flexible Interview Process**
- **Interview Flows** are templates that can be reused across positions
- **Interview Steps** define the sequence and type of interviews
- **Interview Types** are reusable (phone, technical, behavioral, etc.)
- **Interviews** are actual instances with results and feedback

## Migration Strategy

### **Phase 1: Schema Expansion** ✅
- Add ENUMs and new tables
- Modify existing tables with audit fields
- Add indexes and constraints

### **Phase 2: Data Migration** (Future)
- Migrate existing candidate data to new structure
- Create default company for existing data
- Set up initial interview flows and types

### **Phase 3: Application Updates** (Future)
- Update Prisma client generation
- Modify service layer to use new entities
- Update API endpoints for new functionality

## Performance Benchmarks (Target)

### **Expected Query Performance** (with 10K records)
- Candidate search by email: `< 5ms`
- Position listing with filters: `< 50ms`
- Application status updates: `< 10ms`
- Interview scheduling queries: `< 25ms`
- Complex reporting queries: `< 100ms`

### **Scalability Targets**
- **Candidates**: 100K+ records
- **Applications**: 1M+ records  
- **Interviews**: 500K+ records
- **Concurrent Users**: 100+ recruiters

## Security Considerations

### **Data Privacy**
- **Personal Data**: Candidate information properly isolated
- **Access Control**: Employee-based permissions via company relationship
- **Audit Trail**: All entities have created_at/updated_at for tracking changes

### **Data Integrity**
- **Referential Integrity**: Proper foreign key constraints prevent orphaned data
- **Business Rule Enforcement**: ENUMs and unique constraints enforce valid states
- **Cascading Rules**: Logical cascade/restrict rules prevent data inconsistency

## Future Enhancements

### **Potential Optimizations**
1. **Partitioning**: Partition large tables by company_id or date ranges
2. **Caching**: Add Redis for frequently accessed data (active positions, candidate searches)
3. **Search**: Implement full-text search for position descriptions and candidate profiles
4. **Analytics**: Add materialized views for reporting and dashboard queries

### **Additional Features**
1. **File Management**: Enhanced resume and document management
2. **Email Integration**: Interview scheduling and notification system
3. **Reporting**: Advanced analytics and reporting capabilities
4. **API Rate Limiting**: Company-based API quotas and rate limiting

## Testing Recommendations

### **Data Integrity Tests**
```sql
-- Verify no orphaned records
SELECT 'applications' as table_name, count(*) as orphaned_count
FROM applications a 
LEFT JOIN positions p ON a.position_id = p.id 
WHERE p.id IS NULL;
```

### **Performance Tests**
```sql
-- Test common query patterns
EXPLAIN ANALYZE SELECT * FROM positions 
WHERE status = 'PUBLISHED' AND employment_type = 'FULL_TIME' 
ORDER BY created_at DESC LIMIT 20;
```

### **Business Logic Tests**
- Verify unique constraints prevent duplicate applications
- Test cascade delete behavior for companies and candidates
- Validate ENUM constraints reject invalid values
- Confirm interview step ordering within flows

## Conclusion

This schema expansion transforms the simple candidate database into a comprehensive ATS platform while maintaining backwards compatibility and optimizing for performance at scale. The design follows clean architecture principles and database best practices to ensure maintainability and extensibility.

The migration is non-destructive and additive, allowing for a smooth transition from the current system to the expanded functionality while preserving all existing data and relationships.
