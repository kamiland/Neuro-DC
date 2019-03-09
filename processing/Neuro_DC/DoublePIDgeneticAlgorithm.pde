public class DoublePIDgeneticAlgorithm
{
  DoublePIDsimulator[] organism;
  DoublePIDsimulator[] nextGenerationOrganism;
  DoublePIDsimulator best = new DoublePIDsimulator();

  /*static*/  int populationSize; /**ilość osobników w populacji   */
  int generationCounter = 0;

  double bestFit = 0;
  double[] objectParameters;

  double rand;

  double KpRange = 10;
  double KiRange = 10;
  double KdRange = 0;

  double KpRange2 = 10;
  double KiRange2 = 10;
  double KdRange2 = 0;

  long numberOfProbes; /** ilość próbek symulacji   */
  double timeStep;
  private double fitnessSum = 0;

  public DoublePIDgeneticAlgorithm(long _numberOfProbes, int _pupulationSize, double _timeStep)
  {
    numberOfProbes = _numberOfProbes;
    populationSize = _pupulationSize;
    organism = new DoublePIDsimulator[populationSize];
    nextGenerationOrganism = new DoublePIDsimulator[populationSize];
    timeStep = _timeStep;

    for (int i = 0; i < populationSize; i++)
    {
      organism[i] = new DoublePIDsimulator();

      organism[i].angularPID.Kp = ((Math.random() * 2.0) - 1.0) * KpRange; //randomize a P value between -KpRange and KpRange
      organism[i].angularPID.Ki = ((Math.random() * 2.0) - 1.0) * KiRange;
      organism[i].angularPID.Kd = ((Math.random() * 2.0) - 1.0) * KdRange;

      organism[i].currentPID.Kp = ((Math.random() * 2.0) - 1.0) * KpRange2; //randomize a P value between -KpRange and KpRange
      organism[i].currentPID.Ki = ((Math.random() * 2.0) - 1.0) * KiRange2;
      organism[i].currentPID.Kd = ((Math.random() * 2.0) - 1.0) * KdRange2;
    }
  }

  //Przeprowadzenie jednej generacji aż do momentu powstania nowej
  public void doOneGeneration()
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].Simulate(numberOfProbes, timeStep);
    }
    normalizeFitness();
    nextGeneration();
    generationCounter++;
  }


  //Wyświetla najlepszy wynik operacji numerycznych. 
  public double[] showBest()
  {
    best.Simulate(numberOfProbes, timeStep);
    double[] PID = { best.angularPID.Kp, best.angularPID.Ki, best.angularPID.Kd, best.currentPID.Kp, best.currentPID.Ki, best.currentPID.Kd };
    println(PID[0], PID[1], PID[2], '\n', PID[3], PID[4], PID[5]);
    return PID;
  }


  //Utworzenie nowej generacji z bieżącej generacji
  void nextGeneration()
  {
    normalizeFitness();
    for (int k = 0; k < populationSize; k++)
    {
      fitnessSum += organism[k].fitness;
    }

    for (int i = 0; i < populationSize; i++)
    {
      rand = Math.random();
      if ((rand >= 0.5) &&  (fitnessSum > 0.0001 ))
      {
        pickTweak(i);  /**50% szans na przekazanie   */
      } else if ((rand >= 0.1) &&  (fitnessSum > 0.0001 ))
      {
        pickAndCross(i); /** 40% szans skrzyżowania  */
      } else
      {
        mutatant(i); /** 10% szans na losowe nastawy PID */
      }
    }

    for (int i = 0; i < populationSize; i++)
    {
      organism[i] = nextGenerationOrganism[i];
    }
  }


  //Wybór jednego osobnika z populacji oraz delikatna modyfikacja jego nastaw
  void pickTweak(int i)
  {
    DoublePIDsimulator parent = new DoublePIDsimulator();
    int x;
    int j = 0;
    boolean picked;
    double temporarySum = 0;

    if (Math.random() > 0.01)
    {
      picked = false;
      x = (int)(Math.random() * fitnessSum);

      while (!picked && (j < populationSize))
      {
        temporarySum += organism[j].fitness;
        if (temporarySum >= x)
        {
          picked = true;
          parent = organism[j];
        }
        j++;
      }
    } else
    {
      parent = best;
    }
    nextGenerationOrganism[i] = tweak(parent);
  }


  //Wybieranie dwóch osobników z populacji oraz krzyżowanie ich.
  void pickAndCross(int i)
  {
    DoublePIDsimulator parentA = new DoublePIDsimulator();
    int a;
    DoublePIDsimulator parentB = new DoublePIDsimulator();
    int b;
    boolean picked;
    int j = 0;
    double temporarySum = 0;

    a = (int)(Math.random() * fitnessSum);
    picked = false;
    while (!picked && (j < populationSize))
    {
      temporarySum += organism[j].fitness;
      if (temporarySum >= a)
      {
        picked = true;
        parentA = organism[j];
      }
      j++;
    }
    j = 0;

    if (Math.random() > 0.01)
    {
      b = (int)(Math.random() * fitnessSum);
      picked = false;
      while (!picked && (j < populationSize))
      {
        temporarySum += organism[j].fitness;
        if (temporarySum >= b)
        {
          picked = true;
          parentB = organism[j];
        }
        j++;
      }
    } else
    {
      parentB = best; // 1% chance of picking "best" as a pair to cross with
    }
    nextGenerationOrganism[i] = cross(parentA, parentB);
  }

  //Normalizacja wartości fitness wszystkich osobników tak aby były wartościami od 0 do 1
  void normalizeFitness()
  {
    double maxFit = 0;
    double minFit;

    //Oszacowanie maksymalnej wartości fit.
    for (int i = 0; i < populationSize; i++)
    {
      if (organism[i].fitness > maxFit)
      {
        maxFit = organism[i].fitness;
        if (maxFit > bestFit)
        {
          bestFit = maxFit;
          best = organism[i];
        }
      }
    }
    //Oszacowanie minimalnej wartości fit.
    minFit = maxFit;
    for (int i = 0; i < populationSize; i++)
    {
      minFit = organism[i].fitness < minFit ? organism[i].fitness : minFit;
    }

    if (maxFit != 0)
      for (int i = 0; i < populationSize; i++)
      {
        organism[i].fitness -= minFit;
        organism[i].fitness /= (maxFit - minFit);
      }
  }


  //Funkcja tworząca nowy losowy organizm
  void mutatant(int i)
  {
    DoublePIDsimulator child = new DoublePIDsimulator();

    child.angularPID.Kp = ((Math.random() * 2.0) - 1.0) * KpRange; //randomize a P value between -KpRange and KpRange
    child.angularPID.Ki = ((Math.random() * 2.0) - 1.0) * KiRange;
    child.angularPID.Kd = ((Math.random() * 2.0) - 1.0) * KdRange;

    child.currentPID.Kp = ((Math.random() * 2.0) - 1.0) * KpRange2; //randomize a P value between -KpRange and KpRange
    child.currentPID.Ki = ((Math.random() * 2.0) - 1.0) * KiRange2;
    child.currentPID.Kd = ((Math.random() * 2.0) - 1.0) * KdRange2;

    if (Math.random() > 0.01) 
    {
      nextGenerationOrganism[i] = child;
    } else 
    {
      nextGenerationOrganism[i] = best; // 1% chance of picking "best" as a mutant
    }
  }


  //Funkcja delikatnie modyfikująca jeden organizm
  DoublePIDsimulator tweak(DoublePIDsimulator parent) 
  {
    DoublePIDsimulator child = new DoublePIDsimulator();
    child.angularPID.Kp = parent.angularPID.Kp + (Math.random() * 2.0) - 1.0; // value of P +- random between 0 and 1
    child.angularPID.Ki = parent.angularPID.Ki + (Math.random() * 2.0) - 1.0;
    child.angularPID.Kd = parent.angularPID.Kd + (Math.random() * 2.0) - 1.0;

    child.currentPID.Kp = parent.angularPID.Kp + (Math.random() * 2.0) - 1.0; // value of P +- random between 0 and 1
    child.currentPID.Ki = parent.angularPID.Ki + (Math.random() * 2.0) - 1.0;
    child.currentPID.Kd = parent.angularPID.Kd + (Math.random() * 2.0) - 1.0;
    return child;
  }


  //  Funkcja krzyrzująca dwa organizmy
  DoublePIDsimulator cross(DoublePIDsimulator parentA, DoublePIDsimulator parentB)
  {
    DoublePIDsimulator child = new DoublePIDsimulator();
    double crossingPoint = Math.random();
    child.angularPID.Kp = parentA.angularPID.Kp * crossingPoint + parentB.angularPID.Kp * (1.0 - crossingPoint); // picking a new P value in random spot between parentA.P and parentB.P
    crossingPoint = Math.random();
    child.angularPID.Ki = parentA.angularPID.Ki * crossingPoint + parentB.angularPID.Ki * (1.0 - crossingPoint);
    crossingPoint = Math.random();
    child.angularPID.Kd = parentA.angularPID.Kd * crossingPoint + parentB.angularPID.Kd * (1.0 - crossingPoint);

    child.currentPID.Kp = parentA.angularPID.Kp * crossingPoint + parentB.angularPID.Kp * (1.0 - crossingPoint); // picking a new P value in random spot between parentA.P and parentB.P
    crossingPoint = Math.random();
    child.currentPID.Ki = parentA.angularPID.Ki * crossingPoint + parentB.angularPID.Ki * (1.0 - crossingPoint);
    crossingPoint = Math.random();
    child.currentPID.Kd = parentA.angularPID.Kd * crossingPoint + parentB.angularPID.Kd * (1.0 - crossingPoint);

    return child;
  }

  public void SetAbsoluteErrorIntegral()
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].SetAbsoluteErrorIntegral();
    }
  }

  public void SetSquareErrorIntegral()
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].SetSquareErrorIntegral();
    }
  }

  public void SetAngularSaturation(double _minOutput, double _maxOutput)
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].angularPID.saturation = true;
      organism[i].angularPID.minOutput = _minOutput;
      organism[i].angularPID.maxOutput = _maxOutput;
    }
  }
  public void SetCurrentSaturation(double _minOutput, double _maxOutput)
  {
    for (int i = 0; i < populationSize; i++)
    {
      organism[i].currentPID.saturation = true;
      organism[i].currentPID.minOutput = _minOutput;
      organism[i].currentPID.maxOutput = _maxOutput;
    }
  }
}
