public class SinglePIDsimulator extends Simulator
{
  public Controller PID = new Controller
    (
    8.236 // Kp
    , 6.332 // Ki
    , 0.536 // Kd
    , 0 // saturation: MIN
    , 230  // saturation: MAX
    );

  public SinglePIDSimulator() 
  {
  }
  public SinglePIDSimulator(double _setpoint)
  {
    setpoint = _setpoint;
  }

  public double[] Simulate(long numberOfProbes, double timeStep, GPointsArray[] points)
  {
    RK4.x[0] = 0; // rotor current
    RK4.x[1] = 0; // angular velocity

    for (int i = 0; i < numberOfProbes; i++)
    {
      RK4.x = RK4.CalculateNextStep(PID.CalculateOutput(setpoint, RK4.x[1], timeStep), timeStep);

      points[0].add((float) (i * timeStep), (float) RK4.x[0]);
      points[1].add((float) (i * timeStep), (float) RK4.x[1]);

      if (method == errorMethod.absolute)
      {
        errorIntegral += ( abs(setpoint - RK4.x[1]) ) * timeStep;
      } else
      {
        errorIntegral += (setpoint - RK4.x[1])*(setpoint - RK4.x[1]) * timeStep;
      }
    }

    fitness = 1.0 / (errorIntegral + 1.0);
    return RK4.x;
  }

  public double[] Simulate(long numberOfProbes, double timeStep)
  {
    RK4.x[0] = 0; // rotor current
    RK4.x[1] = 0; // angular velocity

    for (int i = 0; i < numberOfProbes; i++)
    {
      RK4.x = RK4.CalculateNextStep(PID.CalculateOutput(setpoint, RK4.x[1], timeStep), timeStep);

      if (method == errorMethod.absolute)
      {
        errorIntegral += ( abs(setpoint - RK4.x[1]) ) * timeStep;
      } else
      {
        errorIntegral += (setpoint - RK4.x[1])*(setpoint - RK4.x[1]) * timeStep;
      }
    }

    fitness = 1.0 / (errorIntegral + 1.0);
    return RK4.x;
  }
}
