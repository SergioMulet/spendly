package com.mulet.spendly.views

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mulet.spendly.R
import com.mulet.spendly.viewmodels.HomeViewModel

@Composable
fun HomeView(
    modifier: Modifier = Modifier,
    viewModel: HomeViewModel = viewModel(),
) {
    Box(modifier = modifier.fillMaxSize()) {
        ExpenseCalendarView(
            viewModel = viewModel,
            modifier = Modifier
                .statusBarsPadding()
                .padding(horizontal = 16.dp, vertical = 8.dp),
        )
        FloatingActionButton(
            onClick = viewModel::addExpenseTapped,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp),
        ) {
            Icon(Icons.Filled.Add, contentDescription = stringResource(R.string.add_expense))
        }
    }
}
