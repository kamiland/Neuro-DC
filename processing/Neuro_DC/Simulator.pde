double abs(double x)
{
  return (x < 0) ? -x : x;
}

interface errorMethod
{
  int
    absolute = 0, 
    square = 1;
}


public class SinglePIDSimulator
{
  //final double PIDtimeStep = 0.001;
  double setpoint = 100;
  public Controller PID = new Controller
    (
    8.236 // Kp
    , 6.332 // Ki
    , 0.536 // Kd
    , 0 // saturation: MIN
    , 230  // saturation: MAX
    );

  public Solver RK4 = new Solver();

  public double fitness = 0;
  double errorIntegral = 0;

  private int method = errorMethod.absolute;

  public void SetAbsoluteErrorIntegral()
  {
    method = errorMethod.absolute;
  }
  public void SetSquareErrorIntegral()
  {
    method = errorMethod.square;
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






public class DoublePIDSimulator
{
  //final double PIDtimeStep = 0.001;
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

  public Solver RK4 = new Solver();

  public double fitness = 0;
  double errorIntegral = 0;

  private int method = errorMethod.absolute;

  public void SetAbsoluteErrorIntegral()
  {
    method = errorMethod.absolute;
  }
  public void SetSquareErrorIntegral()
  {
    method = errorMethod.square;
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
        errorIntegral += ( abs(angularSetpoint - RK4.x[1]) ) * timeStep;
      } else
      {
        errorIntegral += (angularSetpoint - RK4.x[1])*(angularSetpoint - RK4.x[1]) * timeStep;
      }
    }

    fitness = 1.0 / (errorIntegral + 1.0);
    return RK4.x;
  }
}
