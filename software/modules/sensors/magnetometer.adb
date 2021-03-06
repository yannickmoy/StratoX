
with Interfaces; use Interfaces;
with Bounded_Image; use Bounded_Image;

with HMC5883L; use HMC5883L;
with HMC5883L.Driver;


with Logger;
with Interfaces; use Interfaces;

package body Magnetometer with SPARK_Mode is


   --overriding
   procedure initialize (Self : in out Magnetometer_Tag) is
   begin
      Driver.initialize;
      Self.state := READY;
   end initialize;

   --overriding
   procedure read_Measurement(Self : in out Magnetometer_Tag) is
      mag_x, mag_y, mag_z : Integer_16;
   begin
      null;
      --Driver.update_val;
      Driver.getHeading(mag_x, mag_y, mag_z);   -- raw values in micro tesla

      Logger.log_console(Logger.TRACE, "Mag: " & Integer_Img (Integer (mag_x)) & ", "
                 & Integer_Img (Integer (mag_y)) & ", "
                 & Integer_Img (Integer (mag_z)));

      Self.sample.data(X) := Unit_Type(mag_x) * Micro * Tesla;
      Self.sample.data(Y) := Unit_Type(mag_y) * Micro * Tesla;
      Self.sample.data(Z) := Unit_Type(mag_z) * Micro * Tesla;
      -- page 13/19: LSB/Gauss  230 .. 1370, 1090 default

   end read_Measurement;




end Magnetometer;
