ev_info           电梯信息
projectInfo         项目信息
wo_info　　　　　　　　工单信息
wo_info_status　　　电梯保养信息
wo_status   　　　　维保状态
team              班组信息
#项目  梯号	注册代码	负责班组	班长	计划保养时间	类型	签到员工	开始时间	结束时间	花费时间(分钟)	电梯所在地	开始地点	结束地点	来源	计划状态	附件	 维保状态	
#岳阳市二人民医院	2#	31704306022012050002	易文	周建辉	2018/3/21 0:00	保养签到	周建辉	2018/4/19 10:23	2018/4/19 17:14	411	巴陵中路二人民医院	中国湖南省岳阳市岳阳楼区大桥河路	中国湖南省岳阳市岳阳楼区大桥河路	APP端	超期完成	388931:1524129266799.jpg:jpg	正常	


SELECT * FROM team WHERE teamName="易文";


SELECT * FROM ev_info WHERE projectId=1911;
SELECT * FROM projectInfo WHERE name="岳阳市二人民医院";

SELECT name AS 项目,address AS 电梯所在地 FROM projectInfo WHERE name="岳阳市二人民医院";

SELECT * FROM ev_info AS a INNER JOIN projectInfo AS b ON a.projectId = b.uuid WHERE name="岳阳市二人民医院";

＃电梯项目、电梯所在地、注册代码、梯号
SELECT b.name as 项目,b.address AS 电梯所在地,a.regCode AS 注册代码,a.evOrder AS 梯号 FROM ev_info AS a INNER JOIN projectInfo AS b ON a.projectId = b.uuid WHERE name="岳阳市二人民医院";
#维保开始时间、结束时间、花费时间
SELECT a.uuid,a.code,a.companyId,b.startDate,b.endDate,b.woType FROM wo_info AS a INNER JOIN wo_info_status AS b ON a.uuid=b.uuid;
#链接维保信息表
SELECT * FROM wo_info AS a INNER JOIN wo_info_status AS b  INNER JOIN wo_status AS c ON a.uuid=b.uuid ON b.uuid=c.uuid; 
＃班组信息
SELECT * FROM team
SELECT * FROM team WHERE teamName="易文";
SELECT * FROM ev_info;
SELECT * FROM projectInfo AS a INNER JOIN team AS b ON a.uuid=b.uuid;

SELECT * FROM wo_info ;
SELECT * FROM wo_info_status;
SELECT * FROM wo_status;
SELECT * FROM work_order;