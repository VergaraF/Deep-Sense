import test_happy
import test_suspense
import test_scary
import test_sad
import tensorflow as tf

def f(x):
    if(x==1):
##       import random
##       import happy_model  as h
       tf.reset_default_graph() 
       test_happy.run()
##       tf.clear_all_variables()
    elif(x==2):
        tf.reset_default_graph()
        test_sad.run()
    elif(x==3):
        tf.reset_default_graph() 
        test_scary.run()
    elif(x==4):
        tf.reset_default_graph()
        test_suspense.run()
