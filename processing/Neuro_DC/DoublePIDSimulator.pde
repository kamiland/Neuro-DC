public class DoublePIDsimulator extends Simulator
{
  double angularSetpoint = 100;
  double currentSetpoint = 0;
  public Controller angularPID = new Controller
    (
    5.45 // Kp
    , 1.4 // Ki
    , 0 // Kd
    , 0 // saturation: MIN
    , 230  // saturation: MAX
    );

  public Controller currentPID = new Controller
    (
    11.81 // Kp
    , 3.208 // Ki
    , 0 // Kd
    //, 0 // saturation: MIN
    //, 220  // saturation: MAX
    );

  public DoublePIDsimulator()
  {
  }
  public DoublePIDsimulator(double _angularSetpoint)
  {
    angularSetpoint = _angularSetpoint;
  }

  public double[] Simulate(long numberOfProbes, double timeStep, GPointsArray[] points)
  {
    RK4.x[0] = 0; // rotor current
    RK4.x[1] = 0; // angular velocity

    for (int i = 0; i < numberOfProbes; i++)
    {
      currentSetpoint = angularPID.CalculateOutput(angularSetpoint, RK4.x[1], timeStep);
      RK4.x = RK4.CalculateNextStep(currentPID.CalculateOutput(currentSetpoint, RK4.x[0], timeStep), timeStep);

      points[0].add((float) (i * timeStep), (float) RK4.x[0]);
      points[1].add((float) (i * timeStep), (float) RK4.x[1]);

      if (method == errorMethod.absolute)
      {
        errorIntegral += (abs(angularSetpoint - RK4.x[1])) * timeStep /*+ (abs(currentSetpoint - RK4.x[0])) * timeStep*/;
      } else
      {
        errorIntegral += (angularSetpoint - RK4.x[1])*(angularSetpoint - RK4.x[1]) * timeStep /*+ (currentSetpoint - RK4.x[0])*(currentSetpoint - RK4.x[0]) * timeStep*/;
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
      currentSetpoint = angularPID.CalculateOutput(angularSetpoint, RK4.x[1], timeStep);
      RK4.x = RK4.CalculateNextStep(currentPID.CalculateOutput(currentSetpoint, RK4.x[0], timeStep), timeStep);

      if (method == errorMethod.absolute)
      {
        errorIntegral += ( abs(angularSetpoint - RK4.x[1]) ) * timeStep;
      } else
      {
        errorIntegral += (angularSetpoint - RK4.x[1])*(angularSetpoint - RK4.x[1]) * timeStep;
      }
    }

    fitness = 1.0 / (errorIntegral + 1.0);
    //println("\nerrorIntegral: ", errorIntegral);
    return RK4.x;
  }
}
