with Main;
with Config.Tasking;
with Crash; -- must be here, to activate last_chance_handler
with LED_Manager;
pragma Unreferenced (Crash); -- protect the "with" above

-- the entry point after POR

procedure boot is
   pragma Priority (Config.Tasking.TASK_PRIO_MAIN);
   Self_Test_Passed : Boolean := False;
begin

   Main.initialize;

   -- test_System;
   LED_Manager.LED_switchOff;
   Main.perform_Self_Test (Self_Test_Passed);

   -- finally jump to main, if checks passed
   if Self_Test_Passed then
      Main.run_Loop;
   else
      LED_Manager.LED_switchOn;
      loop
         null;
      end loop;
   end if;

end boot;
