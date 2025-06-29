-- ===============================================
-- ATS SCHEMA VALIDATION SCRIPT
-- ===============================================
-- This script validates the database schema after migration
-- Run this to ensure all tables, constraints, and indexes are properly created

\echo 'Starting ATS Schema Validation...'
\echo '=================================='

-- Check if all tables exist
\echo 'Checking table existence...'
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'companies') 
        THEN '✓ companies table exists'
        ELSE '✗ companies table missing'
    END as companies_check
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'employees') 
        THEN '✓ employees table exists'
        ELSE '✗ employees table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'positions') 
        THEN '✓ positions table exists'
        ELSE '✗ positions table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interview_flows') 
        THEN '✓ interview_flows table exists'
        ELSE '✗ interview_flows table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interview_types') 
        THEN '✓ interview_types table exists'
        ELSE '✗ interview_types table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interview_steps') 
        THEN '✓ interview_steps table exists'
        ELSE '✗ interview_steps table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'applications') 
        THEN '✓ applications table exists'
        ELSE '✗ applications table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'interviews') 
        THEN '✓ interviews table exists'
        ELSE '✗ interviews table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'candidates') 
        THEN '✓ candidates table exists (renamed from Candidate)'
        ELSE '✗ candidates table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'educations') 
        THEN '✓ educations table exists (renamed from Education)'
        ELSE '✗ educations table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'work_experiences') 
        THEN '✓ work_experiences table exists (renamed from WorkExperience)'
        ELSE '✗ work_experiences table missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'resumes') 
        THEN '✓ resumes table exists (renamed from Resume)'
        ELSE '✗ resumes table missing'
    END;

\echo ''
\echo 'Checking ENUM types...'
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'position_status') 
        THEN '✓ position_status ENUM exists'
        ELSE '✗ position_status ENUM missing'
    END as enum_check
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employment_type') 
        THEN '✓ employment_type ENUM exists'
        ELSE '✗ employment_type ENUM missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'application_status') 
        THEN '✓ application_status ENUM exists'
        ELSE '✗ application_status ENUM missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'interview_result') 
        THEN '✓ interview_result ENUM exists'
        ELSE '✗ interview_result ENUM missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employee_role') 
        THEN '✓ employee_role ENUM exists'
        ELSE '✗ employee_role ENUM missing'
    END;

\echo ''
\echo 'Checking critical indexes...'
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'companies_name_key') 
        THEN '✓ companies_name unique index exists'
        ELSE '✗ companies_name unique index missing'
    END as index_check
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'employees_email_key') 
        THEN '✓ employees_email unique index exists'
        ELSE '✗ employees_email unique index missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'candidates_email_key') 
        THEN '✓ candidates_email unique index exists'
        ELSE '✗ candidates_email unique index missing'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'applications_position_id_candidate_id_key') 
        THEN '✓ applications unique constraint index exists'
        ELSE '✗ applications unique constraint index missing'
    END;

\echo ''
\echo 'Checking foreign key constraints...'
SELECT 
    conname as constraint_name,
    conrelid::regclass as table_name,
    confrelid::regclass as referenced_table
FROM pg_constraint 
WHERE contype = 'f' 
    AND conrelid::regclass::text IN (
        'companies', 'employees', 'positions', 'interview_flows', 
        'interview_steps', 'interview_types', 'applications', 'interviews',
        'candidates', 'educations', 'work_experiences', 'resumes'
    )
ORDER BY conrelid::regclass, conname;

\echo ''
\echo 'Checking table structures...'
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN (
    'companies', 'employees', 'positions', 'interview_flows',
    'interview_steps', 'interview_types', 'applications', 'interviews'
)
ORDER BY table_name, ordinal_position;

\echo ''
\echo 'Verifying audit fields on existing tables...'
SELECT 
    table_name,
    COUNT(CASE WHEN column_name = 'created_at' THEN 1 END) as has_created_at,
    COUNT(CASE WHEN column_name = 'updated_at' THEN 1 END) as has_updated_at
FROM information_schema.columns 
WHERE table_name IN ('candidates', 'educations', 'work_experiences', 'resumes')
GROUP BY table_name
ORDER BY table_name;

\echo ''
\echo 'Testing ENUM values...'
SELECT 
    t.typname as enum_name,
    e.enumlabel as enum_value
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
WHERE t.typname IN ('position_status', 'employment_type', 'application_status', 'interview_result', 'employee_role')
ORDER BY t.typname, e.enumsortorder;

\echo ''
\echo 'Checking triggers...'
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name LIKE '%updated_at%'
ORDER BY event_object_table;

\echo ''
\echo 'Table row counts (should be 0 for new tables after migration):'
SELECT 'companies' as table_name, count(*) as row_count FROM companies
UNION ALL
SELECT 'employees', count(*) FROM employees
UNION ALL
SELECT 'positions', count(*) FROM positions
UNION ALL
SELECT 'interview_flows', count(*) FROM interview_flows
UNION ALL
SELECT 'interview_types', count(*) FROM interview_types
UNION ALL
SELECT 'interview_steps', count(*) FROM interview_steps
UNION ALL
SELECT 'applications', count(*) FROM applications
UNION ALL
SELECT 'interviews', count(*) FROM interviews
UNION ALL
SELECT 'candidates', count(*) FROM candidates
UNION ALL
SELECT 'educations', count(*) FROM educations
UNION ALL
SELECT 'work_experiences', count(*) FROM work_experiences
UNION ALL
SELECT 'resumes', count(*) FROM resumes
ORDER BY table_name;

\echo ''
\echo 'Data integrity checks...'
-- Check for orphaned records (should return 0 for all)
SELECT 'orphaned_employees' as check_name, count(*) as count
FROM employees e 
LEFT JOIN companies c ON e.company_id = c.id 
WHERE c.id IS NULL

UNION ALL

SELECT 'orphaned_positions', count(*)
FROM positions p 
LEFT JOIN companies c ON p.company_id = c.id 
WHERE c.id IS NULL

UNION ALL

SELECT 'orphaned_applications', count(*)
FROM applications a 
LEFT JOIN positions p ON a.position_id = p.id 
LEFT JOIN candidates c ON a.candidate_id = c.id
WHERE p.id IS NULL OR c.id IS NULL

UNION ALL

SELECT 'invalid_interview_steps', count(*)
FROM interview_steps ist
LEFT JOIN interview_flows if ON ist.interview_flow_id = if.id
LEFT JOIN interview_types it ON ist.interview_type_id = it.id
WHERE if.id IS NULL OR it.id IS NULL;

\echo ''
\echo '=================================='
\echo 'Schema validation completed!'
\echo 'Review results above for any issues marked with ✗'
\echo 'All checks should show ✓ for successful migration'
