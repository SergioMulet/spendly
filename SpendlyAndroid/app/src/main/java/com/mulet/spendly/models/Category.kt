package com.mulet.spendly.models

import androidx.annotation.StringRes
import com.mulet.spendly.R

enum class Category(@StringRes val titleRes: Int) {
    HOUSE(R.string.category_house),
    SPORT(R.string.category_sport),
    CAR(R.string.category_car),
    ENTERTAINMENT(R.string.category_entertainment),
    RESTAURANT(R.string.category_restaurant),
    COMMUNICATION(R.string.category_communication),
    FOOD(R.string.category_food),
    TRANSPORT(R.string.category_transport),
    PET(R.string.category_pet),
    CLOTHES(R.string.category_clothes),
    GIFTS(R.string.category_gifts),
    HEALTH(R.string.category_health),
    OTHER(R.string.category_other);
}
