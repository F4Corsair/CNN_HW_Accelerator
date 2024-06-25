#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TEST_SIZE 10000

int conv_kernel[5][5];	// convolution layer pre-trained weights
int fc_kernel[10][576]; // fc layer pre-trained weights
int image[10000][784];	// MNIST image 28x28 = 784
int label[10000];		// MNIST label

void read_data();
int inference(int index);

int main()
{
	read_data();

	int err = 0;
	for (int i = 0; i < TEST_SIZE; i++)
	{
		if (inference(i) != label[i])
			err++;
	}
	printf("Accuracy: %.2f%%\n", (float)(TEST_SIZE - err) / TEST_SIZE * 100);

	return 0;
}
int inference(int index)
{
	// convolution
	int conv_output[576] = {0};
	for (int col = 0; col < 24; col++)
	{
		for (int row = 0; row < 24; row++)
		{
			for (int kernal_row = 0; kernal_row < 5; kernal_row++)
			{
				for (int kernal_col = 0; kernal_col < 5; kernal_col++)
				{
					conv_output[row * 24 + col] += image[index][(row + kernal_row) * 28 + col + kernal_col] * conv_kernel[kernal_row][kernal_col];
				}
			}
		}
	}

	// relu
	for (int i = 0; i < 576; i++)
	{
		if (conv_output[i] < 0)
			conv_output[i] = 0;
	}

	// fc
	int fc_out[10] = {0};
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 576; j++)
		{
			fc_out[i] += conv_output[j] * fc_kernel[i][j];
		}
	}

	// select result
	int result_index = 0;
	int max_idx = 0;
	int max_num = fc_out[max_idx];
	for (int i = 1; i < 10; i++)
		if (max_num < fc_out[i])
		{
			max_idx = i;
			max_num = fc_out[max_idx];
		}
	result_index = max_idx;

	return result_index;
}
void read_data() // read conv_weight, fc_weight, and MNIST dataset %%% don't fix this function
{
	printf("read data: ");
	FILE *f_conv = fopen("c_conv_kernel.mem", "r");
	if (f_conv == NULL)
	{
		fprintf(stderr, "conv_kernel.mem read fail.\n");
		return;
	}
	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < 5; j++)
		{
			fscanf(f_conv, "%d", &conv_kernel[i][j]);
		}
	}
	fclose(f_conv);

	FILE *f_fc = fopen("c_fc_kernel.mem", "r");
	if (f_fc == NULL)
	{
		fprintf(stderr, "fc_kernel.mem read fail.\n");
		return;
	}
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 576; j++)
		{
			fscanf(f_fc, "%d", &fc_kernel[i][j]);
		}
	}
	fclose(f_fc);

	FILE *f_image = fopen("c_image.mem", "r");
	if (f_image == NULL)
	{
		fprintf(stderr, "image.mem read fail.\n");
		return;
	}
	for (int i = 0; i < 10000; i++)
	{
		for (int j = 0; j < 784; j++)
		{
			fscanf(f_image, "%d", &image[i][j]);
		}
	}
	fclose(f_image);

	FILE *f_label = fopen("c_label.mem", "r");
	if (f_label == NULL)
	{
		fprintf(stderr, "label.mem read fail.\n");
		return;
	}
	for (int i = 0; i < 10000; i++)
	{
		fscanf(f_label, "%d", &label[i]);
	}
	fclose(f_label);
	printf("done\n");
}