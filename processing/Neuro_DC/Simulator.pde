public class Simulator
{
  //final double initialKp = 5, initialKi = 0.2, initialKd = 0.001;
  //final double initialKp = 9.308, initialKi = 6.566, initialKd = 0.951;
  //final double PIDtimeStep = 0.001;
  double setpoint = 100;
  double secondSetpoint = 0;
  public Controller angularPID = new Controller(5.45, 1.4, 0, 0, 230);
  public Controller currentPID = new Controller(11.81, 0.208, 0, 0, 120);
  public Solver RK4 = new Solver();

  //public double fitness = 0;
  //double error_int = 0;


  public double[] Simulate(long numberOfProbes, double timeStep, GPointsArray[] points)
  {
    RK4.x[0] = 0;
    RK4.x[1] = 0;

    for (int i = 0; i < numberOfProbes; i++)
    {
      secondSetpoint = angularPID.CalculateOutput(setpoint, RK4.x[0], timeStep);
      RK4.x = RK4.CalculateNextStep(currentPID.CalculateOutput(secondSetpoint, RK4.x[1], timeStep), timeStep);

      points[0].add(i, (int) RK4.x[0]);
      points[1].add(i, (int) RK4.x[1]);
      //error_int += (Math.Abs(setpoint - RK4.x[1])) * timeStep;
    }

    //fitness = 1.0 / (error_int + 1.0);
    return RK4.x;
  }
}
