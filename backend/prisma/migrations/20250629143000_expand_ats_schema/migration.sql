-- Migration: Expand ATS Schema with Companies, Positions, and Interview Flow
-- Description: Add complete ATS functionality while preserving existing candidate data
-- This migration transforms the current candidate-only database into a full ATS system

-- ===============================================
-- ENUMS - Business Logic Constraints
-- ===============================================

-- Create ENUM types for better data integrity
CREATE TYPE "position_status" AS ENUM ('DRAFT', 'PUBLISHED', 'PAUSED', 'CLOSED', 'CANCELLED');
CREATE TYPE "employment_type" AS ENUM ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'TEMPORARY', 'INTERNSHIP', 'FREELANCE');
CREATE TYPE "application_status" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'INTERVIEW_SCHEDULED', 'INTERVIEWED', 'OFFER_EXTENDED', 'OFFER_ACCEPTED', 'OFFER_DECLINED', 'REJECTED', 'WITHDRAWN');
CREATE TYPE "interview_result" AS ENUM ('PENDING', 'PASSED', 'FAILED', 'NO_SHOW', 'RESCHEDULED');
CREATE TYPE "employee_role" AS ENUM ('HR_MANAGER', 'RECRUITER', 'HIRING_MANAGER', 'INTERVIEWER', 'ADMIN');

-- ===============================================
-- CORE BUSINESS ENTITIES
-- ===============================================

-- Companies table - Central entity for multi-tenant support
CREATE TABLE "companies" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "website" VARCHAR(255),
    "industry" VARCHAR(100),
    "location" VARCHAR(100),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);

-- Employees table - Users who can conduct interviews and manage positions
CREATE TABLE "employees" (
    "id" SERIAL NOT NULL,
    "company_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "role" "employee_role" NOT NULL DEFAULT 'RECRUITER',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- Interview Flows table - Templates for interview processes
CREATE TABLE "interview_flows" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interview_flows_pkey" PRIMARY KEY ("id")
);

-- Interview Types table - Types of interviews (phone, video, technical, etc.)
CREATE TABLE "interview_types" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "duration" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interview_types_pkey" PRIMARY KEY ("id")
);

-- Interview Steps table - Individual steps within an interview flow
CREATE TABLE "interview_steps" (
    "id" SERIAL NOT NULL,
    "interview_flow_id" INTEGER NOT NULL,
    "interview_type_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "order_index" INTEGER NOT NULL,
    "is_required" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interview_steps_pkey" PRIMARY KEY ("id")
);

-- Positions table - Job openings
CREATE TABLE "positions" (
    "id" SERIAL NOT NULL,
    "company_id" INTEGER NOT NULL,
    "interview_flow_id" INTEGER,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT NOT NULL,
    "status" "position_status" NOT NULL DEFAULT 'DRAFT',
    "is_visible" BOOLEAN NOT NULL DEFAULT false,
    "location" VARCHAR(100),
    "job_description" TEXT NOT NULL,
    "requirements" TEXT NOT NULL,
    "responsibilities" TEXT NOT NULL,
    "salary_min" DECIMAL(10,2),
    "salary_max" DECIMAL(10,2),
    "employment_type" "employment_type" NOT NULL,
    "benefits" TEXT,
    "company_description" TEXT,
    "application_deadline" TIMESTAMP(3),
    "contact_info" VARCHAR(255),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "positions_pkey" PRIMARY KEY ("id")
);

-- ===============================================
-- MODIFY EXISTING CANDIDATE TABLES
-- ===============================================

-- Add audit fields to existing Candidate table
ALTER TABLE "Candidate" ADD COLUMN "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "Candidate" ADD COLUMN "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Rename table to follow naming convention
ALTER TABLE "Candidate" RENAME TO "candidates";

-- Add audit fields to Education table and rename columns for consistency
ALTER TABLE "Education" ADD COLUMN "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "Education" ADD COLUMN "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "Education" RENAME COLUMN "startDate" TO "start_date";
ALTER TABLE "Education" RENAME COLUMN "endDate" TO "end_date";
ALTER TABLE "Education" RENAME COLUMN "candidateId" TO "candidate_id";
ALTER TABLE "Education" RENAME TO "educations";

-- Add audit fields to WorkExperience table and rename columns for consistency
ALTER TABLE "WorkExperience" ADD COLUMN "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "WorkExperience" ADD COLUMN "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "WorkExperience" RENAME COLUMN "startDate" TO "start_date";
ALTER TABLE "WorkExperience" RENAME COLUMN "endDate" TO "end_date";
ALTER TABLE "WorkExperience" RENAME COLUMN "candidateId" TO "candidate_id";
ALTER TABLE "WorkExperience" RENAME TO "work_experiences";

-- Add audit fields to Resume table and rename columns for consistency, add new fields
ALTER TABLE "Resume" ADD COLUMN "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "Resume" ADD COLUMN "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "Resume" ADD COLUMN "original_name" VARCHAR(255);
ALTER TABLE "Resume" ADD COLUMN "file_size" INTEGER;
ALTER TABLE "Resume" RENAME COLUMN "filePath" TO "file_path";
ALTER TABLE "Resume" RENAME COLUMN "fileType" TO "file_type";
ALTER TABLE "Resume" RENAME COLUMN "uploadDate" TO "upload_date";
ALTER TABLE "Resume" RENAME COLUMN "candidateId" TO "candidate_id";
ALTER TABLE "Resume" RENAME TO "resumes";

-- ===============================================
-- APPLICATION & INTERVIEW PROCESS ENTITIES
-- ===============================================

-- Applications table - Links candidates to positions
CREATE TABLE "applications" (
    "id" SERIAL NOT NULL,
    "position_id" INTEGER NOT NULL,
    "candidate_id" INTEGER NOT NULL,
    "application_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "application_status" NOT NULL DEFAULT 'SUBMITTED',
    "notes" TEXT,
    "cover_letter" TEXT,
    "expected_salary" DECIMAL(10,2),
    "available_from" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "applications_pkey" PRIMARY KEY ("id")
);

-- Interviews table - Individual interview sessions
CREATE TABLE "interviews" (
    "id" SERIAL NOT NULL,
    "application_id" INTEGER NOT NULL,
    "interview_step_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "interview_date" TIMESTAMP(3) NOT NULL,
    "result" "interview_result" NOT NULL DEFAULT 'PENDING',
    "score" INTEGER,
    "notes" TEXT,
    "feedback" TEXT,
    "duration" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "interviews_pkey" PRIMARY KEY ("id")
);

-- ===============================================
-- CONSTRAINTS AND RELATIONSHIPS
-- ===============================================

-- Companies constraints
ALTER TABLE "companies" ADD CONSTRAINT "companies_name_key" UNIQUE ("name");

-- Employees constraints  
ALTER TABLE "employees" ADD CONSTRAINT "employees_email_key" UNIQUE ("email");
ALTER TABLE "employees" ADD CONSTRAINT "employees_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Interview Types constraints
ALTER TABLE "interview_types" ADD CONSTRAINT "interview_types_name_key" UNIQUE ("name");

-- Interview Steps constraints
ALTER TABLE "interview_steps" ADD CONSTRAINT "interview_steps_interview_flow_id_fkey" FOREIGN KEY ("interview_flow_id") REFERENCES "interview_flows"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "interview_steps" ADD CONSTRAINT "interview_steps_interview_type_id_fkey" FOREIGN KEY ("interview_type_id") REFERENCES "interview_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "interview_steps" ADD CONSTRAINT "interview_steps_interview_flow_id_order_index_key" UNIQUE ("interview_flow_id", "order_index");

-- Positions constraints
ALTER TABLE "positions" ADD CONSTRAINT "positions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "positions" ADD CONSTRAINT "positions_interview_flow_id_fkey" FOREIGN KEY ("interview_flow_id") REFERENCES "interview_flows"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Update existing foreign key constraints to match new table names
ALTER TABLE "educations" DROP CONSTRAINT "Education_candidateId_fkey";
ALTER TABLE "educations" ADD CONSTRAINT "educations_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "candidates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "work_experiences" DROP CONSTRAINT "WorkExperience_candidateId_fkey";  
ALTER TABLE "work_experiences" ADD CONSTRAINT "work_experiences_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "candidates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "resumes" DROP CONSTRAINT "Resume_candidateId_fkey";
ALTER TABLE "resumes" ADD CONSTRAINT "resumes_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "candidates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Applications constraints
ALTER TABLE "applications" ADD CONSTRAINT "applications_position_id_fkey" FOREIGN KEY ("position_id") REFERENCES "positions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "applications" ADD CONSTRAINT "applications_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "candidates"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "applications" ADD CONSTRAINT "applications_position_id_candidate_id_key" UNIQUE ("position_id", "candidate_id");

-- Interviews constraints
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "applications"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_interview_step_id_fkey" FOREIGN KEY ("interview_step_id") REFERENCES "interview_steps"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ===============================================
-- PERFORMANCE INDEXES 
-- ===============================================

-- Companies indexes
CREATE INDEX "companies_name_idx" ON "companies"("name");
CREATE INDEX "companies_industry_idx" ON "companies"("industry");

-- Employees indexes
CREATE INDEX "employees_company_id_idx" ON "employees"("company_id");
CREATE INDEX "employees_email_idx" ON "employees"("email");
CREATE INDEX "employees_is_active_idx" ON "employees"("is_active");

-- Interview Flows indexes
CREATE INDEX "interview_flows_is_active_idx" ON "interview_flows"("is_active");

-- Interview Types indexes
CREATE INDEX "interview_types_is_active_idx" ON "interview_types"("is_active");

-- Interview Steps indexes
CREATE INDEX "interview_steps_interview_flow_id_idx" ON "interview_steps"("interview_flow_id");
CREATE INDEX "interview_steps_interview_type_id_idx" ON "interview_steps"("interview_type_id");

-- Positions indexes
CREATE INDEX "positions_company_id_idx" ON "positions"("company_id");
CREATE INDEX "positions_status_idx" ON "positions"("status");
CREATE INDEX "positions_is_visible_idx" ON "positions"("is_visible");
CREATE INDEX "positions_employment_type_idx" ON "positions"("employment_type");
CREATE INDEX "positions_location_idx" ON "positions"("location");
CREATE INDEX "positions_application_deadline_idx" ON "positions"("application_deadline");

-- Candidates indexes (enhanced)
CREATE INDEX "candidates_email_idx" ON "candidates"("email");
CREATE INDEX "candidates_lastName_firstName_idx" ON "candidates"("lastName", "firstName");

-- Education indexes
CREATE INDEX "educations_candidate_id_idx" ON "educations"("candidate_id");

-- Work Experience indexes  
CREATE INDEX "work_experiences_candidate_id_idx" ON "work_experiences"("candidate_id");

-- Resume indexes
CREATE INDEX "resumes_candidate_id_idx" ON "resumes"("candidate_id");
CREATE INDEX "resumes_upload_date_idx" ON "resumes"("upload_date");

-- Applications indexes
CREATE INDEX "applications_position_id_idx" ON "applications"("position_id");
CREATE INDEX "applications_candidate_id_idx" ON "applications"("candidate_id");
CREATE INDEX "applications_status_idx" ON "applications"("status");
CREATE INDEX "applications_application_date_idx" ON "applications"("application_date");

-- Interviews indexes
CREATE INDEX "interviews_application_id_idx" ON "interviews"("application_id");
CREATE INDEX "interviews_interview_step_id_idx" ON "interviews"("interview_step_id");
CREATE INDEX "interviews_employee_id_idx" ON "interviews"("employee_id");
CREATE INDEX "interviews_interview_date_idx" ON "interviews"("interview_date");
CREATE INDEX "interviews_result_idx" ON "interviews"("result");

-- ===============================================
-- DATA INTEGRITY TRIGGERS (Optional - can be added later)
-- ===============================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at fields on all tables
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON "companies" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON "employees" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_interview_flows_updated_at BEFORE UPDATE ON "interview_flows" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_interview_types_updated_at BEFORE UPDATE ON "interview_types" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_interview_steps_updated_at BEFORE UPDATE ON "interview_steps" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_positions_updated_at BEFORE UPDATE ON "positions" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_candidates_updated_at BEFORE UPDATE ON "candidates" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_educations_updated_at BEFORE UPDATE ON "educations" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_work_experiences_updated_at BEFORE UPDATE ON "work_experiences" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_resumes_updated_at BEFORE UPDATE ON "resumes" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON "applications" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_interviews_updated_at BEFORE UPDATE ON "interviews" FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ===============================================
-- COMMENTS FOR DOCUMENTATION
-- ===============================================

COMMENT ON TABLE "companies" IS 'Companies that use the ATS system';
COMMENT ON TABLE "employees" IS 'Company employees who can manage positions and conduct interviews';
COMMENT ON TABLE "positions" IS 'Job positions/openings posted by companies';
COMMENT ON TABLE "interview_flows" IS 'Templates defining the interview process for positions';
COMMENT ON TABLE "interview_steps" IS 'Individual steps within an interview flow';
COMMENT ON TABLE "interview_types" IS 'Types of interviews (phone, video, technical, etc.)';
COMMENT ON TABLE "applications" IS 'Candidate applications to specific positions';
COMMENT ON TABLE "interviews" IS 'Individual interview sessions conducted as part of applications';

COMMENT ON COLUMN "positions"."salary_min" IS 'Minimum salary range in local currency';
COMMENT ON COLUMN "positions"."salary_max" IS 'Maximum salary range in local currency';
COMMENT ON COLUMN "interviews"."score" IS 'Interview score from 0-100';
COMMENT ON COLUMN "interviews"."duration" IS 'Actual interview duration in minutes';
