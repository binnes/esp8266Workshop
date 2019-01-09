*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [Part 2](../part2/README.md) - [Part 3](../part3/README.md) - [**Part 4**](../part4/README.md)
***
**Part 4** - [Watson Studio](STUDIO.md) - [Training Data](TRAINING.md) - [**Notebooks**](JUPYTER.md) - [ESP8266 model](MODEL.md)
***

# Run a Jupyter Notebook in Watson Studio

## Lab Objectives

In this lab you will read IoT data into a Watson Studio Project Jupyter Notebook and perform some analytics.  You will learn:

- Jupyter Notebooks
- Read data from a Cloudant DB into Spark
- How to create a model to be able to classify the IoT data to determine what is happening.

## Introduction

Jupyter Notebook is a web-based interactive computational environment for interactive data science and scientific computing. A Jupyter Notebook document is a JSON document, following a versioned schema, and containing an ordered list of input/output cells which can contain code, text (using Markdown), mathematics, plots and rich media, usually ending with the ".ipynb" extension. A Jupyter kernel is a program responsible for handling various types of request (code execution, code completions, inspection), and providing a reply.

The steps below will build up the Jupyter notebook, there is a solution notebook at the end to use if you need assistance to complete any step.

## Step 1 - Cloudant Credentials

Before we can read the ESP8266 IoT temperature and humidity data into a Jupyter notebook we need to create credentials for the Cloudant database created in the [Part 3 - Store Data in Cloud Storage](../part3/CLOUDANT.md) section.

- Open a new browser tab.
- Return to the [IBM Cloud dashboard](https://cloud.ibm.com) and your IoT Starter application. **Click** on the cloudantNoSQLDB service connection (1). ![Cloudant NoSQL Service Connection](../part3/screenshots/CloudantNoSQLServiceConnection.png)
- Read about the Cloudant Storage service and click on the **Service credentials** menu item in the left menu bar. ![Cloudant NoSQL Service Instance](screenshots/cloudant-service.png)

- Click on **New credential** ![Cloudant NoSQL Service new](screenshots/cloudant-credential.png)

- Give your credential a name: **Credentials-DSX**
- Click on **Add**
- Expand the **View credentials** twistie
- The Cloudant hostname, user and password credentials will be displayed.
- Keep this browser tab open or copy the credentials to your text editor, as you will use these credentials in the next Step.

### Step 2 - Loading Cloudant data into the Jupyter notebook

When using the lite account on the IBM Cloud there are some restrictions on services.  One restriction is a limit on the number of transactions that can be run in a second (5 database actions per second).  To overcome this we need to ensure that data is extracted from Cloudant at a suitable rate, not to hit thi limit.

- Return to the Watson Studio browser tab and open the **IoT Sensor Analytics** notebook. ![Watson Studio Assets](screenshots/WatsonStudio-Notebook-ESP8266.png)

- Make certain you are in **Edit** mode by clicking on the Pencil icon. ![Watson Studio Edit mode](screenshots/WatsonStudio-Notebook-edit.png)
- Copy the following code into the first cell in the notebook and update the credentials with the values from your cloudant database credentials (created in **step 1**).  The values are from the host, username and password properties in the credentials:

```python
### TODO Please provide your Cloudant credentials in this cell

#Please don't modify this function
def readDataFrameFromCloudant(database):
    cloudantdata=spark.read.load(database, "com.cloudant.spark")
    cloudantdata.createOrReplaceTempView("washing")
    spark.sql("SELECT * from washing").show()
    return cloudantdata

spark = SparkSession\
    .builder\
    .appName("Cloudant Spark SQL Example in Python using temp tables")\
    .config("cloudant.host",'XXXX')\
    .config("cloudant.username", 'XXXX')\
    .config("cloudant.password",'XXXX')\
    .config("jsonstore.rdd.partitions", 1)\
    .getOrCreate()
```

- Press the **Run** button in the toolbar to run the cell ![Run first cell](screenshots/WatsonStudio-cell1.png)
- Move the focus to the next cell and copy in the following python, which calls the function defined in the first cell to load the data from Cloudant training database *(this assumes you used the database name **training** when capturing training data, if not, modify the database name)*:

```python
df=readDataFrameFromCloudant('training')
```

You should see the data from the database.  You can validate that you have the correct data format by checking you have the **class**, **humidity**, **index** and **temperature** columns in the loaded data: ![Load data in to notebook](screenshots/WatsonStudio-cell2.png)

## Step 3 - Work with the training data

Within the notebook you are able to manipulate the data. In this section we will use SQL to create the data frames needed to verify and visualise the training data.  You usually need to examine the training data and maybe clean it up before creating the model.  This section shows some of the techniques available.

- In the next empty cell enter the following code then run the cell.  THis enables you to use SQL statements to manipulate the data, even though it came from a NoSql database:

```python
# Enable SQL on the data frame
df.createOrReplaceTempView('df')
```

- Now we will create a new data frame for each training class.  In the next cell enter then run the following:

```python
df_class_0 = spark.sql('select index, temperature, humidity, class from df where class = 0')
df_class_1 = spark.sql('select index, temperature, humidity, class from df where class = 1')
df_class_0.createOrReplaceTempView('df_class_0')
df_class_1.createOrReplaceTempView('df_class_1')
```

For the rest of this section feel free to explore different options available.  Enter each of the code samples in a cell in the notebook then run the cell to see the results.

- You may want to see what the values the data contains:

```python
# examine the data 
df_class_0.select('temperature', 'humidity').distinct().show()
```

- You can verify the database schema:

```python
df.printSchema()
```

- You can verify the number of records available for each training class and if necessary correct any skew in the number of records available for each class:

```python
spark.sql('select class, count(class) from df group by class').show()
```

If your training data had double the number of entires for class 0 as class 1 then you can create an adjusted data frame to use for training using the following code : ```df_skew_fixed = df_class_0.sample(False, 0.5).union(df_class_1)```, which selects 50% of the records for class 1 and joint them with the records for class 1, so now both classes will have a similar number of records.  However, this should not be necessary as we ensured we captured a similar number of records for each class when training.

- The pixiedust package provides the ability to visualise data in a number of different ways.  Before using the package you need to import it:

```python
# visualisation package for python
import pixiedust
```

- Now you can use the capability of pixiedust to visualise or chart your data:

```python
display(df_class_0)
```

## Step 4 - Creating the binary classifier model

Once you are confident you have the correct training data available you can proceed to creating the model.  

```python
# Imports for modelling
from pyspark.ml.feature import StringIndexer, OneHotEncoder
from pyspark.ml.linalg import Vectors
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.feature import Normalizer

from pyspark.ml import Pipeline
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
```

```python
# create binary classifier model
vectorAssembler = VectorAssembler(inputCols=["humidity","temperature"],
                                  outputCol="features")
lr = LogisticRegression(maxIter=1000).setLabelCol("class")
pipeline = Pipeline(stages=[vectorAssembler, lr ])
model = pipeline.fit(df)
result = model.transform(df)
```

```python
binEval.evaluate(result)
```

```python
model.stages[1].coefficients
```

```python
model.stages[1].intercept
```

## Step 5 - Test the model

```python
#evaluate classification accuracy (1.0 = 100% accurate)
binEval = MulticlassClassificationEvaluator().setMetricName("accuracy").setPredictionCol("prediction").setLabelCol("class")    
binEval.evaluate(result)
```

```python
# test the model
#re-read data from cloudant
new_df = readDataFrameFromCloudant('training')
result = model.transform(new_df)
result.createOrReplaceTempView('result')
spark.sql("select humidity, temperature, class, prediction from result").show(50)
```

## Sample solution

There is a sample solution for this part provided in the [notebooks](notebooks) folder.  If you have an issue and want to see the solution then within the IoT Sensor Analytics project select to add a new notebook.  Select to create a notebook from file and give the notebook a name - here **IoT Sensor Analytics - solution** has been used.  This assumes you have the file locally on your machine.  Select choose file and locate the **IoT Sensor Analytics.ipynb** file.  Finally ensure you have the Default Spark Python 3.5 XS runtime selected then press **Create Notebook**
  ![Import solution](screenshots/WatsonStudio-import-solution.png)

***
**Part 4** - [Watson Studio](STUDIO.md) - [Training Data](TRAINING.md) - [**Notebooks**](JUPYTER.md) - [ESP8266 model](MODEL.md)
***
*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [Part 2](../part2/README.md) - [Part 3](../part3/README.md) - [**Part 4**](../part4/README.md)
