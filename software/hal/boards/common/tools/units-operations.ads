package Units.Operations with SPARK_Mode is

   --  instantiate some useful functions for the units. Cannot be done
   function Sum_Time is new Saturated_Addition (T => Time_Type);

end Units.Operations;
