# Repeat this for all 4 files:
#rm -rf /home/dave/ros/moveit/src/moveit_pr2/pr2_moveit_config/default_warehouse_mongo_db

rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --scene industrial.scene
rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --queries industrial.queries

rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --scene kitchen.scene
rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --queries kitchen.queries

rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --scene narrow_passage.scene
rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --queries narrow_passage_small.queries # SMALL VERSION

rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --scene tabletop.scene
rosrun moveit_ros_warehouse moveit_warehouse_import_from_text --host 127.0.0.1 --port 33829 --queries tabletop.queries