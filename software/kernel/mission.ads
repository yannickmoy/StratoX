
with Estimator;
with Controller;

package Mission is

   -- the mission can only go forward
   type Mission_State_Type is (
      UNKNOWN,
      INITIALIZING,
      SELF_TESTING,
      WAITING_FOR_ARM,
      WAITING_FOR_RELEASE,
      ASCENDING,
      DETACHING,
      DESCENDING,
      WAITING_ON_GROUND,
      --WAITING_FOR_EVALUATION,
      --EVALUATING,
      --WAITING_FOR_RESET
   );

   type Mission_Event_Type is (
      NONE,
      INITIALIZED,
      SELF_TEST_OK,
      ARMED,
      RELEASED,
      BALLOON_DETACHED,
      LANDED,
      FOUND,
      EVALUATED
   );

   procedure start_New_Mission;

   procedure run_Mission;

private
   
   procedure perform_Initialization;

   procedure perform_Self_Test;

   procedure wait_For_Arm;
   
   procedure wait_For_Release;

   procedure monitor_Ascend;
   
   procedure perform_Detach;

   procedure control_Descend;

   procedure wait_On_Ground;

   procedure perform_Evaluation;

end Mission;