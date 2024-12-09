DROP DATABASE IF EXISTS ChiOmega;
CREATE DATABASE ChiOmega;
USE ChiOmega;

DROP TABLE IF EXISTS member;
CREATE TABLE member (
	nuid INT PRIMARY KEY NOT NULL,
    points_ID INT UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    dues_paid ENUM ('on time', 'late', 'not paid') NOT NULL
);

DROP TABLE IF EXISTS points_submission;
CREATE TABLE points_submission (
	submission_ID INT PRIMARY KEY NOT NULL,
    points_ID INT NOT NULL,
    req ENUM ('campus_activity_req', 'CS_req', 'panhel_req', 'MAW_req', 'DEI_req', 'other') NOT NULL,
    hours INT,
    other INT,
    description VARCHAR(200) NOT NULL,
    verified ENUM ('true', 'false') NOT NULL,
    FOREIGN KEY (points_ID) REFERENCES member(points_ID)
);

DROP TABLE IF EXISTS attendance;
CREATE TABLE attendance (
	attendance_ID INT PRIMARY KEY NOT NULL,
    points_ID INT NOT NULL,
    date DATE NOT NULL,
    present ENUM('present', 'excused', 'recurring_excused', 'unexcused') NOT NULL,
    FOREIGN KEY (points_ID) REFERENCES member(points_ID)
);

-- DROP TABLE IF EXISTS points;
-- CREATE TABLE points (
--     points_ID INT PRIMARY KEY NOT NULL,
--     dues INT NOT NULL,
--     campus_activity_req INT NOT NULL,
--     CS_req INT NOT NULL,
--     panhel_req INT NOT NULL,
--     MAW_req INT NOT NULL,
--     DEI_req INT NOT NULL,
--     verified ENUM ('yes', 'no') NOT NULL,
--     FOREIGN KEY (points_ID) REFERENCES member(points_ID)
-- );


-- insert member info
INSERT INTO member (nuid, points_ID, first_name, last_name, email, dues_paid) VALUES
(002217746, 139, "Madeleine", "Tansley", "tansley.m@northeastern.edu", 'late'),
(002319854, 133, "Lilly", "Hover", "hover.l@northeastern.edu", 'on time');

-- delete later...  -->  insert points info
INSERT INTO points_submission (submission_ID, points_ID, req, description, hours, other, verified) VALUES
(1, 139, "campus_activity_req", "econpress club and co op search", null, null, true),
(2, 133, "DEI_req", "dei letter", null, null, true),
(3, 139, "CS_req", "make a wish tabling", 3, null, true),
(4, 139, "CS_req", "make cookies", 2, null, true),
(5, 133, "other", "recruitment", null, 160, true);

-- delete later...  -->  insert attendance info
INSERT INTO attendance (attendance_ID, points_ID, date, present) VALUES
(1, 139, "2024-11-19", 'present'),
(2, 139, "2024-12-03", 'present'),
(3, 133, "2024-12-03", 'recurring_excused');


-- create points table
DROP TABLE IF EXISTS points;
CREATE TABLE points AS
SELECT 
    m.points_ID,
    (a.total_attendance_points + d.dues_points + ps.campus_activity_points
		+ ps.CS_points + ps.MAW_points + ps.panhel_points + ps.DEI_points + ps.other_points) AS "Total Points",
	a.total_attendance_points AS Chapter,
    d.dues_points AS Dues,
    ps.campus_activity_points AS "Campus Activity Req",
    ps.CS_points AS "CS Req",
    ps.MAW_points AS "MAW Req",
    ps.panhel_points AS "Panhel Req",
    ps.DEI_points AS "DEI Req",
    ps.other_points AS "Other"
FROM 
    member m
LEFT JOIN (
    -- calculate each requirement's points
    SELECT 
        points_ID,
        SUM(CASE 
            WHEN req = 'campus_activity_req' THEN 10
            ELSE 0
        END) AS campus_activity_points,
        SUM(CASE 
            WHEN req = 'CS_req' THEN hours
            ELSE 0
        END) AS CS_points,
        SUM(CASE 
            WHEN req = 'panhel_req' THEN 10
            ELSE 0
        END) AS panhel_points,
        SUM(CASE 
            WHEN req = 'MAW_req' THEN 10
            ELSE 0
        END) AS MAW_points,
        SUM(CASE 
            WHEN req = 'DEI_req' THEN 10
            ELSE 0
        END) AS DEI_points,
        SUM(CASE 
            WHEN req = 'other' THEN other
            ELSE 0
        END) AS other_points
    FROM 
        points_submission
    WHERE verified = 'true'
    GROUP BY 
        points_ID
) ps 
ON 
    m.points_ID = ps.points_ID
LEFT JOIN (
    -- calculate total attendance points
    SELECT 
        points_ID,
        SUM(CASE 
            WHEN present = 'present' THEN 10
            WHEN present = 'excused' THEN 5
            WHEN present = 'recurring_excused' THEN 7
            WHEN present = 'unexcused' THEN 0
            ELSE 0
        END) AS total_attendance_points
    FROM 
        attendance
    GROUP BY 
        points_ID
) a 
ON 
	m.points_ID = a.points_ID
LEFT JOIN (
    -- calculate dues points
    SELECT 
        points_ID,
        CASE 
            WHEN dues_paid = 'on time' THEN 10
            WHEN dues_paid = 'late' THEN 5
            WHEN dues_paid = 'not paid' THEN 0
            ELSE 0
        END AS dues_points
    FROM 
        member
) d 
ON 
    m.points_ID = d.points_ID
GROUP BY
	points_ID;


-- show private points table
SELECT * FROM points;

-- show public points table
SELECT 
	m.first_name AS "first name",
    m.last_name AS "last name",
    p.*
 FROM points p
 JOIN member m ON p.points_ID = m. points_ID;