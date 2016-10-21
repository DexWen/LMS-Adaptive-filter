/*
 * zx_lms.c
 * Least Mean Squares Algorithm
 *  Created on: 2013-8-4
 *      Author: monkeyzx
 */
#include "zx_lms.h"
#include "config.h"
#include <stdio.h>
#include <stdlib.h>

static double init_y[] = {4.00,3.30,3.69,2.32};
static double init_x[] = {
		2.104,3,
		1.600,3,
		2.400,3,
		3.000,4
};
static double weight[2] = {0.1, 0.1};

/*
 * Least Mean Square Algorithm
 * return value @error when stop iteration
 * use @lms_prob->method to choose a method.
 */
double lms(struct lms_st *lms_prob)
{
	double err;
	double error;
	int i = 0;
	int j = 0;
	int iter = 0;
	static double *h = 0;       /* 加static,防止栈溢出*/

	h = (double *)malloc(sizeof(double) * lms_prob->m);
	if (!h) {
		return -1;
	}
	do {
		error = 0;

		if (lms_prob->method != STOCHASTIC) {
			i = 0;
		} else {
			/* i=(i+1) mod m */
			i = i + 1;
			if (i >= lms_prob->m) {
				i = 0;
			}
		}

		for ( ; i<lms_prob->m; i++) {
			h[i] = 0;
			for (j=0; j<lms_prob->n; j++) {
				h[i] += lms_prob->weight[j] * lms_prob->x[i*lms_prob->n+j]; /* h(x) */
			}
			if (lms_prob->method == STOCHASTIC) break;   /* handle STOCHASTIC */
		}

		for (j=0; j<lms_prob->n; j++) {
			if (lms_prob->method != STOCHASTIC) {
				i = 0;
			}
			for ( ; i<lms_prob->m; i++) {
				err = lms_prob->lrate
						* (lms_prob->y[i] - h[i]) * lms_prob->x[i*lms_prob->n+j];
				lms_prob->weight[j] += err;            /* Update weights */
				error += ABS(err);
				if (lms_prob->method == STOCHASTIC) break; /* handle STOCHASTIC */
			}
		}

		iter = iter + 1;
		if ((lms_prob->max_iter > 0) && ((iter > lms_prob->max_iter))) {
			break;
		}
	} while (error >= lms_prob->threshhold);

	free(h);

	return error;
}

#define DEBUG
void zx_lms(void)
{
	int i = 0;
	double error = 0;
	struct lms_st lms_prob;

	lms_prob.lrate = 0.01;
	lms_prob.m = 4;
	lms_prob.n = 2;
	lms_prob.weight = weight;
	lms_prob.threshhold = 0.2;
	lms_prob.max_iter = 1000;
	lms_prob.x = init_x;
	lms_prob.y = init_y;
//	lms_prob.method = STOCHASTIC;
	lms_prob.method = BATCH;

//	error = lms(init_x, 2, init_y, 4, weight, 0.01, 0.1, 1000);
	error = lms(&lms_prob);

#ifdef DEBUG
	for (i=0; i<sizeof(weight)/sizeof(weight[0]); i++) {
		printf("%f\n", weight[i]);
	}
	printf("error:%f\n", error);
#endif
}
