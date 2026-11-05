package com.mulet.spendly.views

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.mulet.spendly.R
import com.mulet.spendly.models.MonthGrid
import com.mulet.spendly.viewmodels.HomeViewModel

/** A month calendar. Swipe sideways to change month; tap the title to jump to a month and year. */
@Composable
fun ExpenseCalendarView(viewModel: HomeViewModel, modifier: Modifier = Modifier) {
    val visibleMonth by viewModel.visibleMonth.collectAsStateWithLifecycle()
    val selectedDate by viewModel.selectedDate.collectAsStateWithLifecycle()
    val showingMonthPicker by viewModel.showingMonthPicker.collectAsStateWithLifecycle()
    val locale = LocalConfiguration.current.locales[0]
    val grid = viewModel.monthGrid(visibleMonth, locale)

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(12.dp)) {
        CalendarHeader(
            grid = grid,
            isPickingMonth = showingMonthPicker,
            onTitleClick = { viewModel.setShowingMonthPicker(true) },
            onPrevious = viewModel::showPreviousMonth,
            onNext = viewModel::showNextMonth,
        )
        Column(
            verticalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.pointerInput(Unit) {
                var distance = 0f
                detectHorizontalDragGestures(
                    onDragStart = { distance = 0f },
                    onDragEnd = { viewModel.onCalendarSwipe(distance) },
                    onHorizontalDrag = { _, dragAmount -> distance += dragAmount },
                )
            },
        ) {
            Row {
                grid.weekdaySymbols.forEach { symbol ->
                    Text(
                        text = symbol,
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.weight(1f),
                    )
                }
            }
            grid.weeks.forEach { week ->
                Row {
                    week.forEach { day ->
                        Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                            day?.let { DayCell(it, isSelected = it.date == selectedDate, onClick = { viewModel.selectDate(it.date) }) }
                        }
                    }
                }
            }
        }
    }

    if (showingMonthPicker) {
        MonthYearPickerDialog(
            grid = grid,
            onSelectMonth = viewModel::selectMonth,
            onSelectYear = viewModel::selectYear,
            onDismiss = { viewModel.setShowingMonthPicker(false) },
        )
    }
}

@Composable
private fun CalendarHeader(
    grid: MonthGrid,
    isPickingMonth: Boolean,
    onTitleClick: () -> Unit,
    onPrevious: () -> Unit,
    onNext: () -> Unit,
) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .clip(CircleShape)
                .clickable(onClick = onTitleClick)
                .padding(horizontal = 8.dp, vertical = 4.dp),
        ) {
            Text(
                text = grid.title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                color = if (isPickingMonth) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
            )
            Icon(
                Icons.Filled.KeyboardArrowRight,
                contentDescription = null,
                modifier = Modifier.rotate(if (isPickingMonth) 90f else 0f),
            )
        }
        Box(modifier = Modifier.weight(1f))
        IconButton(onClick = onPrevious) {
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = stringResource(R.string.previous_month))
        }
        IconButton(onClick = onNext) {
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = stringResource(R.string.next_month))
        }
    }
}

@Composable
private fun DayCell(day: MonthGrid.Day, isSelected: Boolean, onClick: () -> Unit) {
    val textColor = when {
        isSelected -> MaterialTheme.colorScheme.onPrimary
        day.isToday -> MaterialTheme.colorScheme.primary
        else -> MaterialTheme.colorScheme.onSurface
    }
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(44.dp)
            .clip(CircleShape)
            .background(if (isSelected) MaterialTheme.colorScheme.primary else Color.Transparent)
            .clickable(onClick = onClick),
    ) {
        Text(
            text = day.number.toString(),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = if (day.isToday) FontWeight.SemiBold else FontWeight.Normal,
            color = textColor,
        )
    }
}

/** Month and year lists side by side, like the iOS wheels. Each tap applies right away. */
@Composable
private fun MonthYearPickerDialog(
    grid: MonthGrid,
    onSelectMonth: (Int) -> Unit,
    onSelectYear: (Int) -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = { TextButton(onClick = onDismiss) { Text(stringResource(R.string.ok)) } },
        text = {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PickerColumn(
                    items = grid.monthNames,
                    selectedIndex = grid.month.monthValue - 1,
                    onSelect = { onSelectMonth(it + 1) },
                    modifier = Modifier.weight(1f),
                )
                PickerColumn(
                    items = grid.years.map { it.toString() },
                    selectedIndex = grid.month.year - grid.years.first,
                    onSelect = { onSelectYear(grid.years.first + it) },
                    modifier = Modifier.weight(1f),
                )
            }
        },
    )
}

@Composable
private fun PickerColumn(
    items: List<String>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val state = rememberLazyListState(initialFirstVisibleItemIndex = (selectedIndex - 2).coerceAtLeast(0))
    LazyColumn(state = state, modifier = modifier.height(220.dp)) {
        itemsIndexed(items) { index, item ->
            val isSelected = index == selectedIndex
            Text(
                text = item,
                style = if (isSelected) MaterialTheme.typography.titleMedium else MaterialTheme.typography.bodyLarge,
                color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(MaterialTheme.shapes.small)
                    .background(if (isSelected) MaterialTheme.colorScheme.primaryContainer else Color.Transparent)
                    .clickable { onSelect(index) }
                    .padding(horizontal = 12.dp, vertical = 10.dp),
            )
        }
    }
}
