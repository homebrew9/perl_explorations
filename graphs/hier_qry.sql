-- #############################################################################
-- Name : hier_qry.sql
-- Desc : Hierarchical query to test Oracle's output when the graph
--        has cycles in it. Compare the output of the Perl program
--        with this. The Perl program should mimic this behavior
--        as closely as possible.
-- By   : r2d2
-- On   : 6-Mar-2015
-- #############################################################################

--
WITH t (caller, callee) AS
(
    SELECT '',  'A' FROM dual UNION ALL
    SELECT '',  'H' FROM dual UNION ALL
    SELECT '',  'G' FROM dual UNION ALL
    SELECT 'A', 'B' FROM dual UNION ALL
    SELECT 'H', 'B' FROM dual UNION ALL
    SELECT 'A', 'C' FROM dual UNION ALL
    SELECT 'B', 'D' FROM dual UNION ALL
    SELECT 'B', 'E' FROM dual UNION ALL
    SELECT 'C', 'F' FROM dual UNION ALL
    SELECT 'G', 'F' FROM dual --UNION ALL
    --SELECT 'G', 'C' FROM dual --UNION ALL
    --SELECT 'E', 'H' FROM dual
    --SELECT 'F', 'A' FROM dual
    --SELECT 'F', 'C' FROM dual
    --SELECT 'F', 'G' FROM dual
)
SELECT caller,
       callee,
       LEVEL,
       NVL2(caller, 0, 1)               AS is_root,
       CONNECT_BY_ROOT callee           AS root_node,
       CONNECT_BY_ISLEAF                AS is_leaf,
       CONNECT_BY_ISCYCLE               AS is_cycle,
       SYS_CONNECT_BY_PATH(callee, '/') AS path
  FROM t
 START WITH caller IS NULL
CONNECT BY nocycle caller = prior callee
;

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- HR Employee Hierarchy query
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--
WITH t (caller, callee) AS
(
    SELECT '',  'A' FROM dual UNION ALL
    SELECT '',  'H' FROM dual UNION ALL
    SELECT '',  'G' FROM dual UNION ALL
    SELECT 'A', 'B' FROM dual UNION ALL
    SELECT 'H', 'B' FROM dual UNION ALL
    SELECT 'A', 'C' FROM dual UNION ALL
    SELECT 'B', 'D' FROM dual UNION ALL
    SELECT 'B', 'E' FROM dual UNION ALL
    SELECT 'C', 'F' FROM dual UNION ALL
    SELECT 'G', 'F' FROM dual --UNION ALL
    --SELECT 'G', 'C' FROM dual --UNION ALL
    --SELECT 'E', 'H' FROM dual
    --SELECT 'F', 'A' FROM dual
    --SELECT 'F', 'C' FROM dual
    --SELECT 'F', 'G' FROM dual
)
SELECT caller,
       callee,
       LEVEL,
       NVL2(caller, 0, 1)               AS is_root,
       CONNECT_BY_ROOT callee           AS root_node,
       CONNECT_BY_ISLEAF                AS is_leaf,
       CONNECT_BY_ISCYCLE               AS is_cycle,
       SYS_CONNECT_BY_PATH(callee, '/') AS path
  FROM t
 START WITH caller IS NULL
CONNECT BY nocycle caller = prior callee
;

--
with t as (
    select e.employee_id as emp_emp_id,
           e.first_name||' '||e.last_name as emp_name,
           e.manager_id as emp_mgr_id,
           m.employee_id as mgr_mgr_id,
           m.first_name||' '||m.last_name as mgr_name
      from hr.employees e
           left outer join hr.employees m
           on ( m.employee_id = e.manager_id)
)
select mgr_name||':'||emp_name as edge_list
  from t
 where emp_mgr_id is not null
;


--
with t as (
    select e.employee_id as emp_id,
           e.first_name||' '||e.last_name as emp_name,
           e.manager_id as emp_mgr_id,
           m.employee_id as mgr_id,
           m.first_name||' '||m.last_name as mgr_name
      from hr.employees e
           left outer join hr.employees m
           on ( m.employee_id = e.manager_id)
)
select mgr_name,
       mgr_id,
       emp_name,
       emp_id,
       LEVEL,
       NVL2(mgr_id, 0, 1)                 AS is_root,
       CONNECT_BY_ROOT emp_name           AS root_node,
       CONNECT_BY_ISLEAF                  AS is_leaf,
       CONNECT_BY_ISCYCLE                 AS is_cycle,
       SYS_CONNECT_BY_PATH(emp_name, '/') AS path
  from t
start with mgr_id is null
connect by nocycle mgr_id = prior emp_id
;

