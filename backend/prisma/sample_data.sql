-- ===============================================
-- SAMPLE DATA FOR TESTING ATS SYSTEM
-- ===============================================
-- This script provides sample data to test the expanded ATS functionality
-- Run this after the main migration to populate the database with test data

-- Insert sample companies
INSERT INTO "companies" ("name", "description", "website", "industry", "location") VALUES
('TechCorp Solutions', 'Leading technology solutions provider', 'https://techcorp.com', 'Technology', 'Madrid, Spain'),
('InnovateLabs', 'Innovation-driven software development company', 'https://innovatelabs.com', 'Software', 'Barcelona, Spain'),
('DataDrive Analytics', 'Big data and analytics consultancy', 'https://datadrive.com', 'Analytics', 'Valencia, Spain');

-- Insert sample employees
INSERT INTO "employees" ("company_id", "name", "email", "role") VALUES
(1, 'Ana García', 'ana.garcia@techcorp.com', 'HR_MANAGER'),
(1, 'Carlos Rodríguez', 'carlos.rodriguez@techcorp.com', 'HIRING_MANAGER'),
(1, 'María López', 'maria.lopez@techcorp.com', 'RECRUITER'),
(2, 'Luis Martín', 'luis.martin@innovatelabs.com', 'HR_MANAGER'),
(2, 'Elena Fernández', 'elena.fernandez@innovatelabs.com', 'INTERVIEWER'),
(3, 'Jorge Sánchez', 'jorge.sanchez@datadrive.com', 'RECRUITER');

-- Insert sample interview types
INSERT INTO "interview_types" ("name", "description", "duration") VALUES
('Phone Screening', 'Initial phone interview to assess basic qualifications', 30),
('Technical Interview', 'In-depth technical assessment of coding and problem-solving skills', 90),
('Behavioral Interview', 'Assessment of soft skills and cultural fit', 60),
('Final Interview', 'Final interview with senior management', 45),
('System Design', 'System design and architecture discussion', 120);

-- Insert sample interview flows
INSERT INTO "interview_flows" ("name", "description") VALUES
('Standard Developer Flow', 'Standard interview process for software developers'),
('Senior Developer Flow', 'Interview process for senior developer positions'),
('Data Analyst Flow', 'Interview process for data analyst positions');

-- Insert sample interview steps
INSERT INTO "interview_steps" ("interview_flow_id", "interview_type_id", "name", "order_index") VALUES
-- Standard Developer Flow
(1, 1, 'Initial Screening', 1),
(1, 3, 'Behavioral Assessment', 2),
(1, 2, 'Technical Assessment', 3),
(1, 4, 'Final Interview', 4),
-- Senior Developer Flow  
(2, 1, 'Initial Screening', 1),
(2, 2, 'Technical Deep Dive', 2),
(2, 5, 'System Design Discussion', 3),
(2, 3, 'Leadership & Culture Fit', 4),
(2, 4, 'Final Interview', 5),
-- Data Analyst Flow
(3, 1, 'Initial Screening', 1),
(3, 2, 'Technical & SQL Assessment', 2),
(3, 3, 'Behavioral Interview', 3),
(3, 4, 'Final Interview', 4);

-- Insert sample positions
INSERT INTO "positions" (
    "company_id", "interview_flow_id", "title", "description", "status", "is_visible",
    "location", "job_description", "requirements", "responsibilities", 
    "salary_min", "salary_max", "employment_type", "benefits", "application_deadline"
) VALUES
(1, 1, 'Frontend Developer', 'React developer for modern web applications', 'PUBLISHED', true,
 'Madrid, Spain', 
 'We are looking for a skilled Frontend Developer to join our team and help build amazing user experiences.',
 'Bachelor''s degree in Computer Science or related field. 3+ years of experience with React, JavaScript, HTML, CSS. Experience with modern frontend tools and frameworks.',
 'Develop and maintain web applications using React. Collaborate with design and backend teams. Write clean, maintainable code. Participate in code reviews.',
 35000.00, 45000.00, 'FULL_TIME', 'Health insurance, flexible schedule, remote work options', '2025-12-31 23:59:59'),

(1, 2, 'Senior Full Stack Developer', 'Lead developer for complex web applications', 'PUBLISHED', true,
 'Madrid, Spain',
 'Senior developer position for experienced professional to lead development projects.',
 'Bachelor''s degree in Computer Science. 5+ years full-stack development experience. Expertise in React, Node.js, PostgreSQL. Leadership experience preferred.',
 'Lead development projects. Mentor junior developers. Design system architecture. Ensure code quality and best practices.',
 55000.00, 70000.00, 'FULL_TIME', 'Health insurance, stock options, flexible schedule, professional development budget', '2025-12-31 23:59:59'),

(2, 1, 'JavaScript Developer', 'Modern JavaScript development role', 'PUBLISHED', true,
 'Barcelona, Spain',
 'Join our innovative team to build cutting-edge JavaScript applications.',
 '2+ years of JavaScript development experience. Knowledge of modern frameworks. Experience with Git and agile methodologies.',
 'Develop JavaScript applications. Work in agile teams. Participate in technical discussions. Contribute to code reviews.',
 30000.00, 40000.00, 'FULL_TIME', 'Health insurance, training opportunities, flexible hours', '2025-12-31 23:59:59'),

(3, 3, 'Data Analyst', 'Analyze and interpret complex datasets', 'PUBLISHED', true,
 'Valencia, Spain',
 'Data analyst position for detail-oriented professional with strong analytical skills.',
 'Degree in Statistics, Mathematics, or related field. Proficiency in SQL, Python/R. Experience with data visualization tools.',
 'Analyze large datasets. Create reports and dashboards. Work with stakeholders to understand data requirements. Present findings to management.',
 32000.00, 42000.00, 'FULL_TIME', 'Health insurance, professional development, flexible schedule', '2025-12-31 23:59:59');

-- Sample applications (these would typically be created when candidates apply)
-- Note: This assumes you have existing candidates in your database
-- You may need to adjust candidate_id values based on your existing data

-- Sample applications for existing candidates (if any exist)
-- INSERT INTO "applications" ("position_id", "candidate_id", "status", "notes") VALUES
-- (1, 1, 'SUBMITTED', 'Strong portfolio, looks promising'),
-- (2, 1, 'UNDER_REVIEW', 'Experienced candidate, good fit for senior role'),
-- (3, 2, 'INTERVIEW_SCHEDULED', 'Phone screening completed successfully');

-- The above INSERT statements for applications are commented out because 
-- they depend on existing candidates in your database. Uncomment and adjust
-- the candidate_id values based on your actual candidate data.

-- ===============================================
-- VALIDATION QUERIES
-- ===============================================
-- Use these queries to verify the data was inserted correctly

-- SELECT 'Companies' as entity, count(*) as total FROM companies
-- UNION ALL
-- SELECT 'Employees' as entity, count(*) as total FROM employees  
-- UNION ALL
-- SELECT 'Interview Types' as entity, count(*) as total FROM interview_types
-- UNION ALL  
-- SELECT 'Interview Flows' as entity, count(*) as total FROM interview_flows
-- UNION ALL
-- SELECT 'Interview Steps' as entity, count(*) as total FROM interview_steps
-- UNION ALL
-- SELECT 'Positions' as entity, count(*) as total FROM positions
-- UNION ALL
-- SELECT 'Applications' as entity, count(*) as total FROM applications;

-- Test complex query to verify relationships
-- SELECT 
--     c.name as company_name,
--     p.title as position_title,
--     p.status as position_status,
--     if.name as interview_flow_name,
--     COUNT(ist.id) as interview_steps_count
-- FROM companies c
-- LEFT JOIN positions p ON c.id = p.company_id
-- LEFT JOIN interview_flows if ON p.interview_flow_id = if.id  
-- LEFT JOIN interview_steps ist ON if.id = ist.interview_flow_id
-- GROUP BY c.id, c.name, p.id, p.title, p.status, if.id, if.name
-- ORDER BY c.name, p.title;
