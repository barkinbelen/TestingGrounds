--liquibase formatted sql
--changeset ebru.polat:001.1
CREATE TABLE TRIAL (
  ID INT NOT null AUTO_INCREMENT,
  NAME VARCHAR(255) null,
  PRIMARY KEY (ID)
)
--rollback DROP SEQUENCE TRIAL_SEQUENCE;
--rollback DROP TABLE TRIAL;

--liquibase formatted sql
--changeset ebru.polat:001.2 context:test
INSERT INTO TRIAL(NAME) VALUES('Test 1');
INSERT INTO TRIAL(NAME) VALUES('Test 2');
--rollback DELETE FROM TRIAL WHERE NAME in('Test 1', 'Test 2');