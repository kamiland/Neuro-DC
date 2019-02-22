public class Simulator
{
  //final double initialKp = 5, initialKi = 0.2, initialKd = 0.001;
  final double initialKp = 9.308, initialKi = 6.566, initialKd = 0.951;
  final double PIDtimeStep = 0.001;
  double setpoint = 150;
  public Controller PID = new Controller(initialKp, initialKi, initialKd);
  public Solver RK4 = new Solver();

  //public double fitness = 0;
  //double error_int = 0;


  public double[] Simulate(long numberOfProbes, double timeStep, GPointsArray[] points)
  {
    RK4.x[0] = 0;
    RK4.x[1] = 0;

    for (int i = 0; i < numberOfProbes; i++)
    {
      RK4.x = RK4.CalculateNextStep(PID.CalculateOutput(setpoint, RK4.x[1], PIDtimeStep), timeStep);

      points[0].add(i, (int) RK4.x[0]);
      points[1].add(i, (int) RK4.x[1]);
      //error_int += (Math.Abs(setpoint - RK4.x[1])) * timeStep;
    }

    //fitness = 1.0 / (error_int + 1.0);
    return RK4.x;
  }
}
