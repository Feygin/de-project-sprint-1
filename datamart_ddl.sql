--создаем витрину в схеме analysis
drop table if exists analysis.dm_rfm_segments;
create table analysis.dm_rfm_segments (
    user_id int4 NOT NULL, 
    recency smallint NOT NULL CHECK (recency >= 1 and recency <= 5),
    frequency smallint NOT NULL CHECK (frequency >= 1 and frequency <= 5), 
    monetary smallint NOT NULL CHECK (monetary >= 1 and monetary <= 5) 
)