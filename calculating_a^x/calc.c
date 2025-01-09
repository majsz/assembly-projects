#include <stdio.h>

extern float _potega(float a, float x);
float potega(float a, float x);

int main() {
	const float FLT_MAX = 3.40282347e+38F;
	const int INT_MAX = 2147483647;
	char c = 'y';
	
	while (c != 'n') {
		printf("Calculate a^x\n");
		float a, x, result=0;
		int p;
		int validInput=0;
		
		printf("Enter a: ");
		do {

			validInput = scanf("%f", &a);
			
			while ((getchar()) != '\n'); 
			if (a <=0 || a > FLT_MAX) { 
				validInput = 0;
			}
			if (validInput <=0) {
				printf("\nPlease enter a positive number: ");
			}
		} while (validInput <= 0);
		
		validInput = 0;
		printf("Enter x: ");
		do {
			validInput = scanf("%f", &x);
			while ((getchar()) != '\n');
			if (x < -FLT_MAX || x > FLT_MAX) {
				validInput = 0;
			}
			if (validInput <=0) {
				printf("\nPlease enter a 'float' number: ");
			}
		} while (validInput <= 0);
		
	
		validInput = 0;
		printf("Enter accuracy: ");
		do {
			validInput = scanf("%d", &p);
			while ((getchar()) != '\n');
			if (p < 0 || p > INT_MAX) {
				validInput = 0;
			}
			if (validInput <= 0) {
				printf("\nPlease enter an integrer: ");
			}
		} while (validInput <= 0);

		result = potega(a, x);
		printf("a^x =~ %.*f\n", p, result);
	
		printf("Press 'y' to make anther calculation, press 'n' to quit: ");
		scanf("%c", &c);
		
		while (c != 'y' && c!= 'n') {
			printf("\nPlease enter 'y' or 'n':");
			while ((getchar()) != '\n');
			scanf("%c", &c);
		}
	}
	return 0;
}
