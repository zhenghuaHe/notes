ev_info           电梯信息
projectInfo         项目信息
wo_info　　　　　　　　工单信息
wo_info_status　　　电梯保养信息
wo_status   　　　　维保状态
team              班组信息
ev_records　　维保公司
companyinfo　维保公司信息

#汕尾市瑞林电梯设备有限公司维保、维修信息汇总
SELECT  b.name,
CASE WHEN a.`type`='1' THEN '维保' ELSE '维修' END,
count(*)
FROM wo_info a,companyinfo b
WHERE a.companyId=b.uuid
AND b.uuid=189328267390488576 AND a.`date` > "2018-07-01 00:00:00" AND a.type IN(1,2)
group BY 1,2

#汕尾市瑞林电梯　维保信息详情
SELECT * FROM wo_info WHERE companyId=189328267390488576 AND `date` > "2018-07-01 00:00:00" AND `type`=1;
#汕尾市瑞林电梯　维修信息详情
SELECT * FROM wo_info WHERE companyId=189328267390488576 AND `date` > "2018-07-01 00:00:00" AND `type`=2;

＃电梯项目、电梯所在地、注册代码、梯号
SELECT b.name as 项目,b.address AS 电梯所在地,a.regCode AS 注册代码,a.evOrder AS 梯号 FROM ev_info AS a INNER JOIN projectInfo AS b ON a.projectId = b.uuid WHERE name="岳阳市二人民医院";
#维保开始时间、结束时间、花费时间
SELECT a.uuid,a.code,a.companyId,b.startDate,b.endDate,b.woType FROM wo_info AS a INNER JOIN wo_info_status AS b ON a.uuid=b.uuid;



SELECT * FROM　companyinfo AS a INNER JOIN ev_info AS b INNER JOIN ev_records AS c INNER JOIN projectInfo AS d ON a.uuid=b.
SELECT * FROM　ev_records AS a INNER JOIN ev_info AS b ON a.evld=b.uuid

SELECT * FROM companyinfo WHERE name LIKE "%瑞林%"
SELECT * FROM companyinfo AS a INNER JOIN ev_records AS b WHERE a.uuid=b.companyId AND a.uuid=189328267390488576

SELECT a.uuid,a.name,a.typeid,a.address,a.createAt,b.uuid,b.companyId,b.evId,b.startTime,b.endTime FROM companyinfo AS a INNER JOIN ev_records AS b ON  a.uuid=b.companyId AND a.uuid=189328267390488576

