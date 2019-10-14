Select m.Title, m.Id, mv.Id, mv.MetricValueDateTime, mv.YValue as Attendance, c.Name as Campus, s.Name as Schedule, mv.Note
from MetricValue mv
Join Metric as m on mv.MetricId = m.Id
Join MetricValuePartition mvpSchedule on mvpSchedule.MetricValueId = mv.Id
Join MetricPartition as mpSchedule on mpSchedule.Id = mvpSchedule.MetricPartitionId
Join EntityType as etSchedule on etSchedule.Id = mpSchedule.EntityTypeId and etSchedule.FriendlyName = 'Schedule'
Join Schedule as s on s.Id = mvpSchedule.EntityId
Join MetricValuePartition mvpCampus on mvpCampus.MetricValueId = mv.Id
Join MetricPartition as mpCampus on mpCampus.Id = mvpCampus.MetricPartitionId
Join EntityType as etCampus on etCampus.Id = mpCampus.EntityTypeId and etCampus.FriendlyName = 'Campus'
Join Campus as c on c.Id = mvpCampus.EntityId
--Where m.Id = 446
Order By mv.MetricValueDateTime
