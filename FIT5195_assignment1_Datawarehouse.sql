/*Drop Table commands*/
DROP TABLE LOCATION_DIM;
DROP TABLE SERVICE_DIM;
DROP TABLE DATE_DIM;
DROP TABLE AGE_GROUP_DIM;
DROP TABLE TIME_PERIOD_DIM;
DROP TABLE COST_TYPE_DIM;
DROP TABLE TEMP_FACT;
DROP TABLE FACT_TABLE;

/* Create table and insert values for dimensions: Location,Service,Date,Age Group, Time period and cost type*/
CREATE TABLE LOCATION_DIM AS SELECT DISTINCT(SUBURB) FROM CLINIC;
SELECT * FROM LOCATION_DIM;
CREATE TABLE SERVICE_DIM AS SELECT SERVICE_ID,S.SERVICE_COST,S.SERVICE_NAME FROM SERVICE S;
SELECT * FROM SERVICE_DIM;
CREATE TABLE DATE_DIM AS SELECT TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON') AS MONTH, TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'YYYY') AS YEAR FROM ASSIGNMENT;
SELECT * FROM DATE_DIM;
CREATE TABLE AGE_GROUP_DIM(AGE_GROUP VARCHAR(10) PRIMARY KEY,AGE_START NUMBER NOT NULL,AGE_END NUMBER NOT NULL);

INSERT INTO AGE_GROUP_DIM VALUES('INFANT',0,1);
INSERT INTO AGE_GROUP_DIM VALUES('CHILDREN',2,17);
INSERT INTO AGE_GROUP_DIM VALUES('ADULT',18,64);
INSERT INTO AGE_GROUP_DIM VALUES('SENIOR',65,200);

SELECT * FROM AGE_GROUP_DIM ;

CREATE TABLE TIME_PERIOD_DIM(TIME_PERIOD_ID VARCHAR(10) PRIMARY KEY,TIME_MONTHS VARCHAR(20) NOT NULL);

INSERT INTO TIME_PERIOD_DIM VALUES('SUMMER','DEC,JAN,FEB');
INSERT INTO TIME_PERIOD_DIM VALUES('WINTER','JUN,JUL,AUG');
INSERT INTO TIME_PERIOD_DIM VALUES('SPRING','SEP,OCT,NOV');
INSERT INTO TIME_PERIOD_DIM VALUES('AUTUMN','MAR,APR,MAY');

SELECT * FROM TIME_PERIOD_DIM ;

CREATE TABLE COST_TYPE_DIM(COST_TYPE VARCHAR(10) PRIMARY KEY,COST_START NUMBER NOT NULL,COST_END NUMBER NOT NULL);

INSERT INTO COST_TYPE_DIM VALUES('LOW',0,19);
INSERT INTO COST_TYPE_DIM VALUES('MEDIUM',20,49);
INSERT INTO COST_TYPE_DIM VALUES('HIGH',50,1000);

SELECT * FROM COST_TYPE_DIM;

/*Creating Temp fact for adding age group, time period and cost type so that its easy to put in fact table*/
CREATE TABLE TEMP_FACT AS SELECT A.PATIENT_ID,P.PATIENT_AGE,A.SERVICE_ID,S.SERVICE_COST,S.HOSPITAL_ID,C.SUBURB,A.ASSIGNMENT_ID,A.PATIENT_SERVICE_START_DATE 
FROM ASSIGNMENT A JOIN SERVICE S ON A.SERVICE_ID = S.SERVICE_ID JOIN PATIENT P ON A.PATIENT_ID=P.PATIENT_ID JOIN CLINIC C ON S.HOSPITAL_ID=C.HOSPITAL_ID;

SELECT * FROM TEMP_FACT;
/*Adding age group, time period and cost type to temp fact*/
ALTER TABLE TEMP_FACT ADD AGE_GROUP VARCHAR(10);
ALTER TABLE TEMP_FACT ADD TIME_PERIOD VARCHAR(10);
ALTER TABLE TEMP_FACT ADD COST_TYPE VARCHAR(10);

UPDATE TEMP_FACT SET AGE_GROUP=CASE 
                     WHEN PATIENT_AGE BETWEEN 0 AND 1 THEN 'INFANT'
                     WHEN PATIENT_AGE BETWEEN 2 AND 17 THEN 'CHILDREN'
                     WHEN PATIENT_AGE BETWEEN 18 AND 64 THEN 'ADULT'
                     WHEN PATIENT_AGE BETWEEN 65 AND 200 THEN 'SENIOR' END;
                     
UPDATE TEMP_FACT SET COST_TYPE=CASE 
                     WHEN SERVICE_COST BETWEEN 0 AND 19 THEN 'LOW'
                     WHEN SERVICE_COST BETWEEN 20 AND 49 THEN 'MEDIUM'
                     WHEN SERVICE_COST BETWEEN 50 AND 1000 THEN 'HIGH'
                     END;
                     
UPDATE TEMP_FACT SET TIME_PERIOD=CASE 
                     WHEN 'DEC,JAN,FEB' LIKE CONCAT(CONCAT('%',TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON')),'%')THEN 'SUMMER'
                     WHEN 'JUN,JUL,AUG' LIKE CONCAT(CONCAT('%',TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON')),'%')THEN 'WINTER'
                     WHEN 'SEP,OCT,NOV' LIKE CONCAT(CONCAT('%',TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON')),'%')THEN 'SPRING'
                     WHEN 'MAR,APR,MAY' LIKE CONCAT(CONCAT('%',TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON')),'%')THEN 'AUTUMN'
                     END;
                     

/* Create Fact table from the temp fact table*/
CREATE TABLE FACT_TABLE AS SELECT TIME_PERIOD,COST_TYPE,SUBURB,AGE_GROUP,TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON') AS MONTH, TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'YYYY') AS YEAR,
SERVICE_ID,COUNT(ASSIGNMENT_ID) AS TOTAL_POPULATION,SUM(SERVICE_COST) AS TOTAL_SERVICE_COST FROM TEMP_FACT
GROUP BY(TIME_PERIOD,COST_TYPE,SUBURB,AGE_GROUP,TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'MON'), TO_CHAR(TO_DATE(PATIENT_SERVICE_START_DATE),'YYYY'),SERVICE_ID);
SELECT * FROM FACT_TABLE;
COMMIT;

